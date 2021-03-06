package sql

import (
	mysql "database/sql"
	"fmt"

	"github.com/btoll/go-invoice/server/app"
)

type Invoice struct {
	Data interface{}
	Stmt map[string]string
}

func NewInvoice(payload interface{}) *Invoice {
	return &Invoice{
		Data: payload,
		Stmt: map[string]string{
			"DELETE":             "DELETE FROM invoice WHERE id=?",
			"GET_ONE":            "SELECT * FROM invoice WHERE id=%d",
			"INSERT":             "INSERT invoice SET company_id=?,dateFrom=?,dateTo=?,url=?,notes=?,rate=?,paid=?",
			"SELECT":             "SELECT %s FROM invoice %s ORDER BY dateFrom DESC",
			"SELECT_TOTAL_HOURS": "SELECT SUM(entry.hours) AS totalHours FROM invoice JOIN entry ON entry.invoice_id=invoice.id WHERE invoice.id=%d",
			"UPDATE":             "UPDATE invoice SET company_id=?,dateFrom=?,dateTo=?,url=?,notes=?,rate=?,paid=? WHERE id=?",
		},
	}
}

func (s *Invoice) GetTotalHours(db *mysql.DB, invoice_id int) (float64, error) {
	rows, err := db.Query(fmt.Sprintf(s.Stmt["SELECT_TOTAL_HOURS"], invoice_id))
	if err != nil {
		return 0, err
	}
	var total_hours float64
	for rows.Next() {
		err = rows.Scan(&total_hours)
		if err != nil {
			// Don't return an error here, 0 is acceptable!
			return 0, nil
		}
	}
	return total_hours, nil
}

func (s *Invoice) Create(db *mysql.DB) (interface{}, error) {
	payload := s.Data.(*app.InvoicePayload)
	stmt, err := db.Prepare(s.Stmt["INSERT"])
	if err != nil {
		return -1, err
	}
	res, err := stmt.Exec(payload.CompanyID, payload.DateFrom, payload.DateTo, payload.URL, payload.Notes, payload.Rate, payload.Paid)
	if err != nil {
		return -1, err
	}
	id, err := res.LastInsertId()
	if err != nil {
		return -1, err
	}
	return &app.InvoiceMedia{
		ID:        int(id),
		CompanyID: int(payload.CompanyID),
		DateFrom:  payload.DateFrom,
		DateTo:    payload.DateTo,
		URL:       payload.URL,
		Notes:     payload.Notes,
		Rate:      payload.Rate,
		Paid:      payload.Paid,
	}, nil
}

func (s *Invoice) Read(db *mysql.DB) (interface{}, error) {
	id := s.Data.(int)
	rows, err := db.Query(fmt.Sprintf(s.Stmt["GET_ONE"], id))
	if err != nil {
		return nil, err
	}
	total_hours, err := s.GetTotalHours(db, id)
	if err != nil {
		return nil, err
	}
	row := &app.InvoiceMedia{}
	for rows.Next() {
		var company_id int
		var dateFrom string
		var dateTo string
		var url string
		var notes string
		var rate float64
		var paid bool
		err = rows.Scan(&id, &company_id, &dateFrom, &dateTo, &url, &notes, &rate, &paid)
		if err != nil {
			return nil, err
		}
		row.ID = id
		row.CompanyID = company_id
		row.DateFrom = dateFrom
		row.DateTo = dateTo
		row.URL = url
		row.Notes = notes
		row.Rate = rate
		row.Paid = paid
		row.TotalHours = total_hours
	}
	return row, nil
}

func (s *Invoice) Update(db *mysql.DB) error {
	payload := s.Data.(*app.InvoicePayload)
	stmt, err := db.Prepare(s.Stmt["UPDATE"])
	if err != nil {
		return err
	}
	_, err = stmt.Exec(payload.CompanyID, payload.DateFrom, payload.DateTo, payload.URL, payload.Notes, payload.Rate, payload.Paid, payload.ID)
	return err
}

func (s *Invoice) Delete(db *mysql.DB) error {
	// NOTE: B/c of the foreign key constraint and deletion cascade, deleting an invoice will automatically delete all of its entries!
	stmt, err := db.Prepare(s.Stmt["DELETE"])
	if err != nil {
		return err
	}
	invoiceId := s.Data.(int)
	_, err = stmt.Exec(&invoiceId)
	return err
}

func (s *Invoice) List(db *mysql.DB) (interface{}, error) {
	company_id := s.Data.(int)
	var rows *mysql.Rows
	var err error
	if company_id == -1 {
		rows, err = db.Query(fmt.Sprintf(s.Stmt["SELECT"], "COUNT(*)", ""))
		if err != nil {
			return nil, err
		}
	} else {
		rows, err = db.Query(fmt.Sprintf(s.Stmt["SELECT"], "COUNT(*)", fmt.Sprintf("WHERE company_id=%d", company_id)))
		if err != nil {
			return nil, err
		}
	}
	var count int
	for rows.Next() {
		err = rows.Scan(&count)
		if err != nil {
			return nil, err
		}
	}
	if company_id == -1 {
		rows, err = db.Query(fmt.Sprintf(s.Stmt["SELECT"], "*", ""))
		if err != nil {
			return nil, err
		}
	} else {
		rows, err = db.Query(fmt.Sprintf(s.Stmt["SELECT"], "*", fmt.Sprintf("WHERE company_id=%d", company_id)))
		if err != nil {
			return nil, err
		}
	}
	coll := make(app.InvoiceMediaCollection, count)
	i := 0
	for rows.Next() {
		var id int
		var company_id int
		var dateFrom string
		var dateTo string
		var url string
		var notes string
		var rate float64
		var paid bool
		err = rows.Scan(&id, &company_id, &dateFrom, &dateTo, &url, &notes, &rate, &paid)
		if err != nil {
			return nil, err
		}
		entries, err := List(NewEntry(id))
		if err != nil {
			return nil, err
		}
        total_hours, err := s.GetTotalHours(db, id)
		if err != nil {
			return nil, err
		}
		coll[i] = &app.InvoiceMedia{
			ID:         id,
			CompanyID:  company_id,
			DateFrom:   dateFrom,
			DateTo:     dateTo,
			URL:        url,
			Notes:      notes,
			Rate:       rate,
			Paid:       paid,
			TotalHours: total_hours,
			Entries:    entries.(app.EntryMediaCollection),
		}
		i++
	}
	return coll, nil
}
