package main

import (
	"html/template"
	"os"
	"time"

	"github.com/btoll/go-invoice/server/app"
	"github.com/btoll/go-invoice/server/sql"
	"github.com/btoll/go-invoice/server/view"
	"github.com/goadesign/goa"
)

// InvoiceController implements the Invoice resource.
type InvoiceController struct {
	*goa.Controller
}

// NewInvoiceController creates a Invoice controller.
func NewInvoiceController(service *goa.Service) *InvoiceController {
	return &InvoiceController{Controller: service.NewController("InvoiceController")}
}

// Create runs the create action.
func (c *InvoiceController) Create(ctx *app.CreateInvoiceContext) error {
	// InvoiceController_Create: start_implement

	res, err := sql.Create(sql.NewInvoice(ctx.Payload))
	if err != nil {
		return ctx.BadRequest(goa.ErrInternal(err, "endpoint", "create"))
	}
	return ctx.OK(res.(*app.InvoiceMedia))

	// InvoiceController_Create: end_implement
}

// Delete runs the delete action.
func (c *InvoiceController) Delete(ctx *app.DeleteInvoiceContext) error {
	// InvoiceController_Delete: start_implement

	err := sql.Delete(sql.NewInvoice(ctx.ID))
	if err != nil {
		//		return ctx.BadRequest(goa.ErrInternal(err, "endpoint", "delete"))
		//		err = ctx.BadRequest(goa.ErrInternal(err, "endpoint", "delete"))
		//		return goa.ErrInternal(err, "endpoint", "delete")
		return goa.ErrBadRequest(err, "endpoint", "delete")
	}
	return ctx.OKTiny(&app.InvoiceMediaTiny{ctx.ID})

	// InvoiceController_Delete: end_implement
}

// List runs the list action.
func (c *InvoiceController) List(ctx *app.ListInvoiceContext) error {
	// InvoiceController_List: start_implement

	collection, err := sql.List(sql.NewInvoice(ctx.CompanyID))
	if err != nil {
		return ctx.BadRequest(goa.ErrInternal(err, "endpoint", "list"))
	}
	return ctx.OK(collection.(app.InvoiceMediaCollection))

	// InvoiceController_List: end_implement
}

func (c *InvoiceController) Export(ctx *app.ExportInvoiceContext) error {
	// InvoiceController_Export: start_implement

	rec, err := sql.Read(sql.NewInvoice(ctx.ID))
	if err != nil {
		return ctx.BadRequest(goa.ErrInternal(err, "endpoint", "export"))
	}
	entries, err := sql.List(sql.NewEntry(ctx.ID))
	if err != nil {
		return goa.ErrInternal(err, "endpoint", "export")
	}
	row := rec.(*app.InvoiceMedia)
	row.Entries = entries.(app.EntryMediaCollection)
	company, err := sql.Read(sql.NewCompany(row.CompanyID))
	if err != nil {
		return goa.ErrInternal(err, "endpoint", "export")
	}
	current_time := time.Now().Local()
	inv := view.Invoice{
		CurrentDate: current_time.Format("01/02/2006"),
		Amount:      row.Rate * row.TotalHours,
		Company:     company.(*app.CompanyMedia),
		Invoice:     row,
	}
	f, err := os.Create("invoices/foo.html")
	if err != nil {
		return ctx.BadRequest(goa.ErrInternal(err, "endpoint", "export"))
	}
	defer f.Close()
	tmpl := template.Must(template.New("invoice.tmpl").ParseFiles("view/invoice.tmpl"))
	err = tmpl.Execute(f, inv)
	if err != nil {
		return ctx.BadRequest(goa.ErrInternal(err, "endpoint", "export"))
	}
	err = f.Sync()
	if err != nil {
		return ctx.BadRequest(goa.ErrInternal(err, "endpoint", "export"))
	}
	return ctx.OKTiny(&app.InvoiceMediaTiny{ctx.ID})

	// InvoiceController_Export: end_implement
}

// Show runs the show action.
func (c *InvoiceController) Show(ctx *app.ShowInvoiceContext) error {
	// InvoiceController_Show: start_implement

	rec, err := sql.Read(sql.NewInvoice(ctx.ID))
	if err != nil {
		return goa.ErrInternal(err, "endpoint", "show")
	}
	return ctx.OK(rec.(*app.InvoiceMedia))

	// InvoiceController_Show: end_implement
}

// Update runs the update action.
func (c *InvoiceController) Update(ctx *app.UpdateInvoiceContext) error {
	// InvoiceController_Update: start_implement

	err := sql.Update(sql.NewInvoice(ctx.Payload))
	if err != nil {
		return goa.ErrInternal(err, "endpoint", "update")
	}
	return ctx.OKTiny(&app.InvoiceMediaTiny{*ctx.Payload.ID})

	// InvoiceController_Update: end_implement
}
