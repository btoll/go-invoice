package view

import (
	"github.com/btoll/go-invoice/server/app"
)

type Invoice struct {
	CurrentDate string
	Amount      float64
	Company     *app.CompanyMedia
	Invoice     *app.InvoiceMedia
	//	ID          int                      `json:"id"`
	//	Title       string                   `json:"title"`
	//	CurrentDate string                   `json:"currentDate"`
	//	TotalHours  float64                  `json:"totalHours"`
	//	Amount      float64                  `json:"amount"`
	//	DateFrom    string                   `json:"dateFrom"`
	//	DateTo      string                   `json:"dateTo"`
	//	URL         string                   `json:"url"`
	//	Comment     string                   `json:"comment"`
	//	Rate        float64                  `json:"rate"`
	//	Entries     app.EntryMediaCollection `json:"entries"`
}
