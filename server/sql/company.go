package sql

import (
	mysql "database/sql"
	"fmt"

	"github.com/btoll/go-invoice/server/app"
)

type Company struct {
	Data interface{}
	Stmt map[string]string
}

func NewCompany(payload interface{}) *Company {
	return &Company{
		Data: payload,
		Stmt: map[string]string{
			"DELETE":  "DELETE FROM company WHERE id=?",
			"GET_ONE": "SELECT * FROM company WHERE id=%d",
			"INSERT":  "INSERT company SET name=?,contact=?,street1=?,street2=?,city=?,state=?,zip=?,url=?,comment=?",
			"SELECT":  "SELECT %s FROM company",
			"UPDATE":  "UPDATE company SET name=?,contact=?,street1=?,street2=?,city=?,state=?,zip=?,url=?,comment=? WHERE id=?",
		},
	}
}

func (s *Company) Create(db *mysql.DB) (interface{}, error) {
	payload := s.Data.(*app.CompanyPayload)
	stmt, err := db.Prepare(s.Stmt["INSERT"])
	if err != nil {
		return -1, err
	}
	res, err := stmt.Exec(payload.Name, payload.Contact, payload.Street1, payload.Street2, payload.City, payload.State, payload.Zip, payload.URL, payload.Comment)
	if err != nil {
		return -1, err
	}
	id, err := res.LastInsertId()
	if err != nil {
		return -1, err
	}
	return &app.CompanyMedia{
		ID:      int(id),
		Name:    payload.Name,
		Contact: payload.Contact,
		Street1: payload.Street1,
		Street2: payload.Street2,
		City:    payload.City,
		State:   payload.State,
		Zip:     payload.Zip,
		URL:     payload.URL,
		Comment: payload.Comment,
	}, nil
}

func (s *Company) Read(db *mysql.DB) (interface{}, error) {
	rows, err := db.Query(fmt.Sprintf(s.Stmt["GET_ONE"], s.Data.(int)))
	if err != nil {
		return nil, err
	}
	row := &app.CompanyMedia{}
	for rows.Next() {
		var id int
		var name string
		var contact string
		var street1 string
		var street2 string
		var city string
		var state string
		var zip string
		var url string
		var comment string
		err = rows.Scan(&id, &name, &contact, &street1, &street1, &city, &state, &zip, &url, &comment)
		if err != nil {
			return nil, err
		}
		row.ID = id
		row.Name = name
		row.Contact = contact
		row.Street1 = street1
		row.Street2 = street2
		row.City = city
		row.State = state
		row.Zip = zip
		row.URL = url
		row.Comment = comment
	}
	return row, nil
}

func (s *Company) Update(db *mysql.DB) error {
	payload := s.Data.(*app.CompanyPayload)
	stmt, err := db.Prepare(s.Stmt["UPDATE"])
	if err != nil {
		return err
	}
	_, err = stmt.Exec(payload.Name, payload.Contact, payload.Street1, payload.Street2, payload.City, payload.State, payload.Zip, payload.URL, payload.Comment, payload.ID)
	return err
}

func (s *Company) Delete(db *mysql.DB) error {
	// NOTE: B/c of the foreign key constraint and deletion cascade, deleting an company will automatically delete all of its invoices and entries!
	stmt, err := db.Prepare(s.Stmt["DELETE"])
	if err != nil {
		return err
	}
	companyId := s.Data.(int)
	_, err = stmt.Exec(&companyId)
	return err
}

func (s *Company) List(db *mysql.DB) (interface{}, error) {
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
	coll := make(app.CompanyMediaCollection, count)
	i := 0
	for rows.Next() {
		var id int
		var name string
		var contact string
		var street1 string
		var street2 string
		var city string
		var state string
		var zip string
		var url string
		var comment string
		err = rows.Scan(&id, &name, &contact, &street1, &street2, &city, &state, &zip, &url, &comment)
		if err != nil {
			return nil, err
		}
		invoices, err := List(NewInvoice(id))
		if err != nil {
			return nil, err
		}
		coll[i] = &app.CompanyMedia{
			ID:       id,
			Name:     name,
			Contact:  contact,
			Street1:  street1,
			Street2:  street2,
			City:     city,
			State:    state,
			Zip:      zip,
			URL:      url,
			Comment:  comment,
			Invoices: invoices.(app.InvoiceMediaCollection),
		}
		i++
	}
	return coll, nil
}
