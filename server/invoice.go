package main

import (
	"encoding/json"

	"github.com/btoll/go-invoice/server/app"
	"github.com/btoll/go-invoice/server/sql"
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

	collection, err := sql.List(sql.NewInvoice(nil))
	if err != nil {
		return ctx.BadRequest(goa.ErrInternal(err, "endpoint", "list"))
	}
	return ctx.OK(collection.(app.InvoiceMediaCollection))

	// InvoiceController_List: end_implement
}

func (c *InvoiceController) Print(ctx *app.PrintInvoiceContext) error {
	// InvoiceController_Print: start_implement

	type Invoice struct {
		ID         int                      `json:"id"`
		Title      string                   `json:"title"`
		DateFrom   string                   `json:"dateFrom"`
		DateTo     string                   `json:"dateTo"`
		URL        string                   `json:"url"`
		Comment    string                   `json:"comment"`
		Rate       float64                  `json:"rate"`
		TotalHours float64                  `json:"totalHours"`
		Entries    app.EntryMediaCollection `json:"entries"`
	}
	rec, err := sql.Read(sql.NewInvoice(ctx.ID))
	if err != nil {
		return ctx.BadRequest(goa.ErrInternal(err, "endpoint", "print"))
	}
	entries, err := sql.List(sql.NewEntry(ctx.ID))
	if err != nil {
		return goa.ErrInternal(err, "endpoint", "print")
	}
	ctx.ResponseData.Header().Set("Content-Disposition", "attachment; filename=DERP.json")
	ctx.ResponseData.Header().Set("Content-Type", ctx.RequestData.Header.Get("Content-Type"))
	//	ctx.ResponseData.Header().Set("Content-Type", "application/octet-stream")
	// TODO: This isn't working!
	//	ctx.ResponseData.Header().Set("Content-Length", string(ctx.ResponseData.Length))
	row := rec.(*app.InvoiceMedia)
	b, err := json.Marshal(Invoice{
		ID:         row.ID,
		Title:      row.Title,
		DateFrom:   row.DateFrom,
		DateTo:     row.DateTo,
		Rate:       row.Rate,
		TotalHours: row.TotalHours,
		Entries:    entries.(app.EntryMediaCollection),
	})
	if err != nil {
		return ctx.BadRequest(goa.ErrInternal(err, "endpoint", "print"))
	}
	return ctx.OK(b)

	// InvoiceController_Print: end_implement
}

// Show runs the show action.
func (c *InvoiceController) Show(ctx *app.ShowInvoiceContext) error {
	// InvoiceController_Show: start_implement

	rec, err := sql.Read(sql.NewInvoice(ctx.ID))
	if err != nil {
		return goa.ErrInternal(err, "endpoint", "print")
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
