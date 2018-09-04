package view

import (
	"github.com/btoll/go-invoice/server/app"
)

type Invoice struct {
	ID          int                      `json:"id"`
	Title       string                   `json:"title"`
	CurrentDate string                   `json:"currentDate"`
	Amount      float64                  `json:"amount"`
	DateFrom    string                   `json:"dateFrom"`
	DateTo      string                   `json:"dateTo"`
	URL         string                   `json:"url"`
	Comment     string                   `json:"comment"`
	Rate        float64                  `json:"rate"`
	TotalHours  float64                  `json:"totalHours"`
	Entries     app.EntryMediaCollection `json:"entries"`
}
