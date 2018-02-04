package main

import (
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
		return err
	}
	return ctx.OK(res.(*app.InvoiceMedia))

	// InvoiceController_Create: end_implement
}

// Delete runs the delete action.
func (c *InvoiceController) Delete(ctx *app.DeleteInvoiceContext) error {
	// InvoiceController_Delete: start_implement

	err := sql.Delete(sql.NewInvoice(ctx.ID))
	if err != nil {
		return err
	}
	return ctx.OKTiny(&app.InvoiceMediaTiny{ctx.ID})

	// InvoiceController_Delete: end_implement
}

// List runs the list action.
func (c *InvoiceController) List(ctx *app.ListInvoiceContext) error {
	// InvoiceController_List: start_implement

	collection, err := sql.List(sql.NewInvoice(nil))
	if err != nil {
		return err
	}
	return ctx.OK(collection.(app.InvoiceMediaCollection))

	// InvoiceController_List: end_implement
}

// Show runs the show action.
func (c *InvoiceController) Show(ctx *app.ShowInvoiceContext) error {
	// InvoiceController_Show: start_implement

	//	res := &app.InvoiceMedia{}
	//	return ctx.OK(res)
	return nil

	// InvoiceController_Show: end_implement
}

// Update runs the update action.
func (c *InvoiceController) Update(ctx *app.UpdateInvoiceContext) error {
	// InvoiceController_Update: start_implement

	err := sql.Update(sql.NewInvoice(ctx.Payload))
	if err != nil {
		return err
	}
	return ctx.OKTiny(&app.InvoiceMediaTiny{*ctx.Payload.ID})

	// InvoiceController_Update: end_implement
}
