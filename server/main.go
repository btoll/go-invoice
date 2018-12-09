//go:generate goagen bootstrap -d github.com/btoll/go-invoice/server/design

package main

import (
	"github.com/btoll/go-invoice/server/app"
	"github.com/goadesign/goa"
	"github.com/goadesign/goa/middleware"
)

func main() {
	// Create service
	service := goa.New("go-invoice")

	// Mount middleware
	service.Use(middleware.RequestID())
	service.Use(middleware.LogRequest(true))
	service.Use(middleware.ErrorHandler(service, true))
	service.Use(middleware.Recover())

	// Mount "Invoice" controller
	c := NewInvoiceController(service)
	app.MountInvoiceController(service, c)
	d := NewEntryController(service)
	app.MountEntryController(service, d)
	e := NewCompanyController(service)
	app.MountCompanyController(service, e)

	// Start service
	if err := service.ListenAndServe(":8090"); err != nil {
		service.LogError("startup", "err", err)
	}
}
