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
	return mysql.Open("mysql", ":@/?charset=utf8")
}

func Create(s SQL) (interface{}, error) {
	db, err := connect()
	if err != nil {
		return -1, err
	}
	rec, err := s.Create(db)
	if err != nil {
		return -1, err
	}
	cleanup(db)
	return rec, nil
}

func Read(s SQL) (interface{}, error) {
	db, err := connect()
	if err != nil {
		return nil, err
	}
	coll, err := s.Read(db)
	if err != nil {
		return nil, err
	}
	cleanup(db)
	return coll, nil
}

func Update(s SQL) error {
	db, err := connect()
	if err != nil {
		return err
	}
	err = s.Update(db)
	if err != nil {
		return err
	}
	cleanup(db)
	return nil
}

func Delete(s SQL) error {
	db, err := connect()
	if err != nil {
		return err
	}
	err = s.Delete(db)
	cleanup(db)
	return nil
}

func List(s SQL) (interface{}, error) {
	db, err := connect()
	if err != nil {
		return nil, err
	}
	coll, err := s.List(db)
	if err != nil {
		return nil, err
	}
	cleanup(db)
	return coll, nil
}
