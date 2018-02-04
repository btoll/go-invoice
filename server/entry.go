package main

import (
	"github.com/btoll/go-invoice/server/app"
	"github.com/btoll/go-invoice/server/sql"
	"github.com/goadesign/goa"
)

// EntryController implements the Entry resource.
type EntryController struct {
	*goa.Controller
}

// NewEntryController creates a Entry controller.
func NewEntryController(service *goa.Service) *EntryController {
	return &EntryController{Controller: service.NewController("EntryController")}
}

// Create runs the create action.
func (c *EntryController) Create(ctx *app.CreateEntryContext) error {
	// EntryController_Create: start_implement

	res, err := sql.Create(sql.NewEntry(ctx.Payload))
	if err != nil {
		return err
	}
	return ctx.OK(res.(*app.EntryMedia))

	// EntryController_Create: end_implement
}

// Delete runs the delete action.
func (c *EntryController) Delete(ctx *app.DeleteEntryContext) error {
	// EntryController_Delete: start_implement

	err := sql.Delete(sql.NewEntry(ctx.ID))
	if err != nil {
		return err
	}
	return ctx.OKTiny(&app.EntryMediaTiny{ctx.ID})

	// EntryController_Delete: end_implement
}

// List runs the list action.
func (c *EntryController) List(ctx *app.ListEntryContext) error {
	// EntryController_List: start_implement

	collection, err := sql.List(sql.NewEntry(ctx.InvoiceID))
	if err != nil {
		return err
	}
	return ctx.OK(collection.(app.EntryMediaCollection))

	// EntryController_List: end_implement
}

// Show runs the show action.
func (c *EntryController) Show(ctx *app.ShowEntryContext) error {
	// EntryController_Show: start_implement

	return nil
	//	res := &app.EntryMedia{}
	//	return ctx.OK(res)
	// EntryController_Show: end_implement
}

// Update runs the update action.
func (c *EntryController) Update(ctx *app.UpdateEntryContext) error {
	// EntryController_Update: start_implement

	err := sql.Update(sql.NewEntry(ctx.Payload))
	if err != nil {
		return err
	}
	return ctx.OKTiny(&app.EntryMediaTiny{*ctx.Payload.ID})

	// EntryController_Update: end_implement
}
