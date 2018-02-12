package sql

import (
	mysql "database/sql"

	_ "github.com/go-sql-driver/mysql"
)

type SQL interface {
	Create(db *mysql.DB) (interface{}, error)
	Read(db *mysql.DB) (interface{}, error)
	Update(db *mysql.DB) error
	Delete(db *mysql.DB) error
	List(db *mysql.DB) (interface{}, error)
}

func cleanup(db *mysql.DB) error {
	return db.Close()
}

func connect() (*mysql.DB, error) {
	return mysql.Open("mysql", "root:aa892sbr@/invoices?charset=utf8")
}

func Create(s SQL) (interface{}, error) {
	db, err := connect()
	if err != nil {
		return -1, err
	}
	rec, err := s.Create(db)
	cleanup(db)
	return rec, err
}

func Read(s SQL) (interface{}, error) {
	db, err := connect()
	if err != nil {
		return nil, err
	}
	row, err := s.Read(db)
	cleanup(db)
	return row, err
}

func Update(s SQL) error {
	db, err := connect()
	if err != nil {
		return err
	}
	err = s.Update(db)
	cleanup(db)
	return err
}

func Delete(s SQL) error {
	db, err := connect()
	if err != nil {
		return err
	}
	err = s.Delete(db)
	cleanup(db)
	return err
}

func List(s SQL) (interface{}, error) {
	db, err := connect()
	if err != nil {
		return nil, err
	}
	coll, err := s.List(db)
	cleanup(db)
	return coll, err
}
