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
			"DELETE": "DELETE FROM invoice WHERE id=?",
			"INSERT": "INSERT invoice SET dateFrom=?,dateTo=?,title=?,url=?,comment=?,rate=?,totalHours=?",
			"SELECT": "SELECT %s FROM invoice",
			"UPDATE": "UPDATE invoice SET dateFrom=?,dateTo=?,title=?,url=?,comment=?,rate=?,totalHours=? WHERE id=?",
		},
	}
}

func (s *Invoice) Create(db *mysql.DB) (interface{}, error) {
	payload := s.Data.(*app.InvoicePayload)
	stmt, err := db.Prepare(s.Stmt["INSERT"])
	if err != nil {
		return -1, err
	}
	res, err := stmt.Exec(payload.DateFrom, payload.DateTo, payload.Title, payload.URL, payload.Comment, payload.Rate, payload.TotalHours)
	if err != nil {
		return -1, err
	}
	id, err := res.LastInsertId()
	if err != nil {
		return -1, err
	}
	return &app.InvoiceMedia{
		ID:         int(id),
		DateFrom:   payload.DateFrom,
		DateTo:     payload.DateTo,
		Title:      payload.Title,
		URL:        payload.URL,
		Comment:    payload.Comment,
		Rate:       payload.Rate,
		TotalHours: payload.TotalHours,
	}, nil
}

func (s *Invoice) Read(db *mysql.DB) (interface{}, error) {
	return nil, nil
}

func (s *Invoice) Update(db *mysql.DB) error {
	payload := s.Data.(*app.InvoicePayload)
	stmt, err := db.Prepare(s.Stmt["UPDATE"])
	if err != nil {
		return err
	}
	_, err = stmt.Exec(payload.DateFrom, payload.DateTo, payload.Title, payload.URL, payload.Comment, payload.Rate, payload.TotalHours, payload.ID)
	return err
}

func (s *Invoice) Delete(db *mysql.DB) error {
	stmt, err := db.Prepare(s.Stmt["DELETE"])
	if err != nil {
		return err
	}
	id := s.Data.(int)
	_, err = stmt.Exec(&id)
	return err
}

func (s *Invoice) List(db *mysql.DB) (interface{}, error) {
	rows, err := db.Query(fmt.Sprintf(s.Stmt["SELECT"], "COUNT(*)"))
	if err != nil {
		return nil, err
	}
	var count int
	for rows.Next() {
		err = rows.Scan(&count)
		if err != nil {
			return nil, err
		}
	}
	rows, err = db.Query(fmt.Sprintf(s.Stmt["SELECT"], "*"))
	if err != nil {
		return nil, err
	}
	coll := make(app.InvoiceMediaCollection, count)
	i := 0
	for rows.Next() {
		var id int
		var title string
		var dateFrom string
		var dateTo string
		var url string
		var comment string
		var rate float64
		var totalHours float64
		err = rows.Scan(&id, &title, &dateFrom, &dateTo, &url, &comment, &rate, &totalHours)
		if err != nil {
			return nil, err
		}
		coll[i] = &app.InvoiceMedia{
			ID:         id,
			Title:      title,
			DateFrom:   dateFrom,
			DateTo:     dateTo,
			URL:        url,
			Comment:    comment,
			Rate:       rate,
			TotalHours: totalHours,
		}
		i++
	}
	return coll, nil
}
