package design

import (
	. "github.com/goadesign/goa/design"
	. "github.com/goadesign/goa/design/apidsl"
)

var _ = Resource("Company", func() {
	BasePath("/company")
	Description("Describes an company.")

	Action("create", func() {
		Routing(POST("/"))
		Description("Create a new company.")
		Payload(CompanyPayload)
		Response(OK, CompanyMedia)
		Response(BadRequest, ErrorMedia)
	})

	Action("show", func() {
		Routing(GET("/:id"))
		Params(func() {
			Param("id", Integer, "Company ID")
		})
		Description("Get an company by id.")
		Response(OK, CompanyMedia)
		Response(BadRequest, ErrorMedia)
	})

	Action("update", func() {
		Routing(PUT("/:id"))
		Payload(CompanyPayload)
		Params(func() {
			Param("id", Integer, "Company ID")
		})
		Description("Update an company by id.")
		Response(OK, func() {
			Status(200)
			Media(CompanyMedia, "tiny")
		})
		Response(BadRequest, ErrorMedia)
	})

	Action("delete", func() {
		Routing(DELETE("/:id"))
		Params(func() {
			Param("id", Integer, "Company ID")
		})
		Description("Delete an company by id.")
		Response(OK, func() {
			Status(200)
			Media(CompanyMedia, "tiny")
		})
		Response(BadRequest, ErrorMedia)
	})

	Action("list", func() {
		Routing(GET("/list"))
		Description("Get all companys")
		Response(OK, CollectionOf(CompanyMedia))
		Response(BadRequest, ErrorMedia)
	})
})

var CompanyPayload = Type("CompanyPayload", func() {
	Description("Company Description.")

	Attribute("id", Integer, "ID", func() {
		Metadata("struct:tag:datastore", "id,noindex")
		Metadata("struct:tag:json", "id")
	})
	Attribute("name", String, "Company name", func() {
		Metadata("struct:tag:datastore", "name,noindex")
		Metadata("struct:tag:json", "name")
	})
	Attribute("contact", String, "Company contact", func() {
		Metadata("struct:tag:datastore", "contact,noindex")
		Metadata("struct:tag:json", "contact")
	})
	Attribute("street1", String, "Company street1", func() {
		Metadata("struct:tag:datastore", "street1,noindex")
		Metadata("struct:tag:json", "street1")
	})
	Attribute("street2", String, "Company street2", func() {
		Metadata("struct:tag:datastore", "street2,noindex")
		Metadata("struct:tag:json", "street2")
	})
	Attribute("city", String, "Company city", func() {
		Metadata("struct:tag:datastore", "city,noindex")
		Metadata("struct:tag:json", "city")
	})
	Attribute("state", String, "Company state", func() {
		Metadata("struct:tag:datastore", "state,noindex")
		Metadata("struct:tag:json", "state")
	})
	Attribute("zip", String, "Company zip", func() {
		Metadata("struct:tag:datastore", "zip,noindex")
		Metadata("struct:tag:json", "zip")
	})
	Attribute("url", String, "Company url", func() {
		Metadata("struct:tag:datastore", "url,noindex")
		Metadata("struct:tag:json", "url")
	})
	Attribute("comment", String, "Company comment", func() {
		Metadata("struct:tag:datastore", "comment,noindex")
		Metadata("struct:tag:json", "comment")
	})
	Attribute("invoices", Any, "Company invoices", func() {
		Metadata("struct:tag:datastore", "invoices,noindex")
		Metadata("struct:tag:json", "invoices")
	})

	Required("name", "contact", "street1", "street2", "city", "state", "zip", "url", "comment")
})

var CompanyMedia = MediaType("application/companyapi.companyentity", func() {
	Description("Company response")
	TypeName("CompanyMedia")
	ContentType("application/json")
	Reference(CompanyPayload)

	Attributes(func() {
		Attribute("id")
		Attribute("name")
		Attribute("contact")
		Attribute("street1")
		Attribute("street2")
		Attribute("city")
		Attribute("state")
		Attribute("zip")
		Attribute("url")
		Attribute("comment")
		Attribute("invoices", CollectionOf(InvoiceMedia))

		Required("id", "name", "contact", "street1", "street2", "city", "state", "zip", "url", "comment", "invoices")
	})

	View("default", func() {
		Attribute("id")
		Attribute("name")
		Attribute("contact")
		Attribute("street1")
		Attribute("street2")
		Attribute("city")
		Attribute("state")
		Attribute("zip")
		Attribute("url")
		Attribute("comment")
		Attribute("invoices")
	})

	View("tiny", func() {
		Attribute("id")
	})
})
