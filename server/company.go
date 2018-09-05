package main

import (
	"github.com/btoll/go-invoice/server/app"
	"github.com/btoll/go-invoice/server/sql"
	"github.com/goadesign/goa"
)

// CompanyController implements the Company resource.
type CompanyController struct {
	*goa.Controller
}

// NewCompanyController creates a Company controller.
func NewCompanyController(service *goa.Service) *CompanyController {
	return &CompanyController{Controller: service.NewController("CompanyController")}
}

// Create runs the create action.
func (c *CompanyController) Create(ctx *app.CreateCompanyContext) error {
	// CompanyController_Create: start_implement

	res, err := sql.Create(sql.NewCompany(ctx.Payload))
	if err != nil {
		return ctx.BadRequest(goa.ErrInternal(err, "endpoint", "create"))
	}
	return ctx.OK(res.(*app.CompanyMedia))

	// CompanyController_Create: end_implement
}

// Delete runs the delete action.
func (c *CompanyController) Delete(ctx *app.DeleteCompanyContext) error {
	// CompanyController_Delete: start_implement

	err := sql.Delete(sql.NewCompany(ctx.ID))
	if err != nil {
		//		return ctx.BadRequest(goa.ErrInternal(err, "endpoint", "delete"))
		//		err = ctx.BadRequest(goa.ErrInternal(err, "endpoint", "delete"))
		//		return goa.ErrInternal(err, "endpoint", "delete")
		return goa.ErrBadRequest(err, "endpoint", "delete")
	}
	return ctx.OKTiny(&app.CompanyMediaTiny{ctx.ID})

	// CompanyController_Delete: end_implement
}

// List runs the list action.
func (c *CompanyController) List(ctx *app.ListCompanyContext) error {
	// CompanyController_List: start_implement

	collection, err := sql.List(sql.NewCompany(nil))
	if err != nil {
		return ctx.BadRequest(goa.ErrInternal(err, "endpoint", "list"))
	}
	return ctx.OK(collection.(app.CompanyMediaCollection))

	// CompanyController_List: end_implement
}

// Show runs the show action.
func (c *CompanyController) Show(ctx *app.ShowCompanyContext) error {
	// CompanyController_Show: start_implement

	rec, err := sql.Read(sql.NewCompany(ctx.ID))
	if err != nil {
		return goa.ErrInternal(err, "endpoint", "show")
	}
	return ctx.OK(rec.(*app.CompanyMedia))

	// CompanyController_Show: end_implement
}

// Update runs the update action.
func (c *CompanyController) Update(ctx *app.UpdateCompanyContext) error {
	// CompanyController_Update: start_implement

	err := sql.Update(sql.NewCompany(ctx.Payload))
	if err != nil {
		return goa.ErrInternal(err, "endpoint", "update")
	}
	return ctx.OKTiny(&app.CompanyMediaTiny{*ctx.Payload.ID})

	// CompanyController_Update: end_implement
}
