package view

import (
	"github.com/btoll/go-invoice/server/app"
)

type Invoice struct {
	CurrentDate string
	Amount      float64
	Company     *app.CompanyMedia
	Invoice     *app.InvoiceMedia
}

/*
func (i *Invoice) ParseReferences(references string) []string {
	return strings.Fields(references)
}
*/
