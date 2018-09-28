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
