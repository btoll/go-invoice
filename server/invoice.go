package main

import (
	"github.com/btoll/go-invoice/server/app"
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

	// Put your logic here

	res := &app.InvoiceMedia{}
	return ctx.OK(res)
	// InvoiceController_Create: end_implement
}

// Delete runs the delete action.
func (c *InvoiceController) Delete(ctx *app.DeleteInvoiceContext) error {
	// InvoiceController_Delete: start_implement

	// Put your logic here

	res := &app.InvoiceMediaTiny{}
	return ctx.OKTiny(res)
	// InvoiceController_Delete: end_implement
}

// List runs the list action.
func (c *InvoiceController) List(ctx *app.ListInvoiceContext) error {
	// InvoiceController_List: start_implement

	// Put your logic here

	res := app.InvoiceMediaCollection{}
	return ctx.OK(res)
	// InvoiceController_List: end_implement
}

// Show runs the show action.
func (c *InvoiceController) Show(ctx *app.ShowInvoiceContext) error {
	// InvoiceController_Show: start_implement

	// Put your logic here

	res := &app.InvoiceMedia{}
	return ctx.OK(res)
	// InvoiceController_Show: end_implement
}

// Update runs the update action.
func (c *InvoiceController) Update(ctx *app.UpdateInvoiceContext) error {
	// InvoiceController_Update: start_implement

	// Put your logic here

	res := &app.InvoiceMediaTiny{}
	return ctx.OKTiny(res)
	// InvoiceController_Update: end_implement
}
