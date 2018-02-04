package sql

import (
	mysql "database/sql"
	"fmt"

	"github.com/btoll/go-invoice/server/app"
)

type Entry struct {
	Data interface{}
	Stmt map[string]string
}

func NewEntry(payload interface{}) *Entry {
	return &Entry{
		Data: payload,
		Stmt: map[string]string{
			"DELETE": "DELETE FROM entry WHERE id=?",
			"INSERT": "INSERT entry SET invoice_id=?,date=?,title=?,url=?,comment=?,hours=?",
			"SELECT": "SELECT %s FROM entry WHERE invoice_id=%d",
			"UPDATE": "UPDATE entry SET invoice_id=?,date=?,title=?,url=?,comment=?,hours=? WHERE id=?",
		},
	}
}

func (s *Entry) Create(db *mysql.DB) (interface{}, error) {
	payload := s.Data.(*app.EntryPayload)
	stmt, err := db.Prepare(s.Stmt["INSERT"])
	if err != nil {
		return -1, err
	}
	res, err := stmt.Exec(payload.InvoiceID, payload.Date, payload.Title, payload.URL, payload.Comment, payload.Hours)
	if err != nil {
		return -1, err
	}
	id, err := res.LastInsertId()
	if err != nil {
		return -1, err
	}
	return &app.EntryMedia{
		ID:        int(id),
		InvoiceID: payload.InvoiceID,
		Date:      payload.Date,
		Title:     payload.Title,
		URL:       payload.URL,
		Comment:   payload.Comment,
		Hours:     payload.Hours,
	}, nil
}

func (s *Entry) Read(db *mysql.DB) (interface{}, error) {
	return nil, nil
}

func (s *Entry) Update(db *mysql.DB) error {
	payload := s.Data.(*app.EntryPayload)
	stmt, err := db.Prepare(s.Stmt["UPDATE"])
	if err != nil {
		return err
	}
	_, err = stmt.Exec(payload.InvoiceID, payload.Date, payload.Title, payload.URL, payload.Comment, payload.Hours, payload.ID)
	return err
}

func (s *Entry) Delete(db *mysql.DB) error {
	stmt, err := db.Prepare(s.Stmt["DELETE"])
	if err != nil {
		return err
	}
	id := s.Data.(int)
	_, err = stmt.Exec(&id)
	return err
}

func (s *Entry) List(db *mysql.DB) (interface{}, error) {
	invoice_id := s.Data.(int)
	rows, err := db.Query(fmt.Sprintf(s.Stmt["SELECT"], "COUNT(*)", invoice_id))
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
	rows, err = db.Query(fmt.Sprintf(s.Stmt["SELECT"], "*", invoice_id))
	if err != nil {
		return nil, err
	}
	coll := make(app.EntryMediaCollection, count)
	i := 0
	for rows.Next() {
		var id int
		var invoice_id int
		var title string
		var date string
		var url string
		var comment string
		var hours float64
		err = rows.Scan(&id, &invoice_id, &title, &date, &url, &comment, &hours)
		if err != nil {
			return nil, err
		}
		coll[i] = &app.EntryMedia{
			ID:        id,
			InvoiceID: invoice_id,
			Title:     title,
			Date:      date,
			URL:       url,
			Comment:   comment,
			Hours:     hours,
		}
		i++
	}
	return coll, nil
}
