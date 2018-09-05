package design

import (
	. "github.com/goadesign/goa/design"
	. "github.com/goadesign/goa/design/apidsl"
)

var _ = Resource("Invoice", func() {
	BasePath("/invoice")
	Description("Describes an invoice.")

	Action("create", func() {
		Routing(POST("/"))
		Description("Create a new invoice.")
		Payload(InvoicePayload)
		Response(OK, InvoiceMedia)
		Response(BadRequest, ErrorMedia)
	})

	Action("show", func() {
		Routing(GET("/:id"))
		Params(func() {
			Param("id", Integer, "Invoice ID")
		})
		Description("Get an invoice by id.")
		Response(OK, InvoiceMedia)
		Response(BadRequest, ErrorMedia)
	})

	Action("update", func() {
		Routing(PUT("/:id"))
		Payload(InvoicePayload)
		Params(func() {
			Param("id", Integer, "Invoice ID")
		})
		Description("Update an invoice by id.")
		Response(OK, func() {
			Status(200)
			Media(InvoiceMedia, "tiny")
		})
		Response(BadRequest, ErrorMedia)
	})

	Action("delete", func() {
		Routing(DELETE("/:id"))
		Params(func() {
			Param("id", Integer, "Invoice ID")
		})
		Description("Delete an invoice by id.")
		Response(OK, func() {
			Status(200)
			Media(InvoiceMedia, "tiny")
		})
		Response(BadRequest, ErrorMedia)
	})

	Action("list", func() {
		Routing(GET("/list/:company_id"))
		Params(func() {
			Param("company_id", Integer, "Company ID")
		})
		Description("Get all invoices")
		Response(OK, CollectionOf(InvoiceMedia))
		Response(BadRequest, ErrorMedia)
	})

	Action("export", func() {
		Routing(GET("/export/:id"))
		Params(func() {
			Param("id", Integer, "Invoice ID")
		})
		Description("Export an invoice")
		Response(OK, func() {
			Status(200)
			Media(InvoiceMedia, "tiny")
		})
		Response(BadRequest, ErrorMedia)
	})
})

var InvoicePayload = Type("InvoicePayload", func() {
	Description("Invoice Description.")

	Attribute("id", Integer, "ID", func() {
		Metadata("struct:tag:datastore", "id,noindex")
		Metadata("struct:tag:json", "id")
	})
	Attribute("company_id", Integer, "Company ID (foreign key)", func() {
		Metadata("struct:tag:datastore", "company_id,noindex")
		Metadata("struct:tag:json", "company_id")
	})
	Attribute("title", String, "Invoice title", func() {
		Metadata("struct:tag:datastore", "title,noindex")
		Metadata("struct:tag:json", "title")
	})
	Attribute("dateFrom", String, "Invoice date from", func() {
		Metadata("struct:tag:datastore", "dateFrom,noindex")
		Metadata("struct:tag:json", "dateFrom")
	})
	Attribute("dateTo", String, "Invoice date to", func() {
		Metadata("struct:tag:datastore", "dateTo,noindex")
		Metadata("struct:tag:json", "dateTo")
	})
	Attribute("url", String, "Invoice url", func() {
		Metadata("struct:tag:datastore", "url,noindex")
		Metadata("struct:tag:json", "url")
	})
	Attribute("comment", String, "Invoice comment", func() {
		Metadata("struct:tag:datastore", "comment,noindex")
		Metadata("struct:tag:json", "comment")
	})
	Attribute("rate", Number, "Invoice rate", func() {
		Metadata("struct:tag:datastore", "rate,noindex")
		Metadata("struct:tag:json", "rate")
	})
	Attribute("totalHours", Number, "Invoice total hours", func() {
		Metadata("struct:tag:datastore", "totalHours")
		// Note that the following statement is needed b/c the json response was returned with
		// `TotalHours` in the payload which was not being correctly parsed into the client-side
		// model b/c Elm was expecting it to be camel-case `totalHours`!
		Metadata("struct:tag:json", "totalHours")
	})
	Attribute("entries", Any, "Invoice entries", func() {
		Metadata("struct:tag:datastore", "entries,noindex")
		Metadata("struct:tag:json", "entries")
	})

	Required("company_id", "title", "dateFrom", "dateTo", "url", "comment", "rate", "totalHours")
})

var InvoiceMedia = MediaType("application/invoiceapi.invoiceentity", func() {
	Description("Invoice response")
	TypeName("InvoiceMedia")
	ContentType("application/json")
	Reference(InvoicePayload)

	Attributes(func() {
		Attribute("id")
		Attribute("company_id")
		Attribute("title")
		Attribute("dateFrom")
		Attribute("dateTo")
		Attribute("url")
		Attribute("comment")
		Attribute("rate")
		Attribute("totalHours")
		Attribute("entries", CollectionOf(EntryMedia))

		Required("id", "company_id", "title", "dateFrom", "dateTo", "url", "comment", "rate", "totalHours", "entries")
	})

	View("default", func() {
		Attribute("id")
		Attribute("company_id")
		Attribute("title")
		Attribute("dateFrom")
		Attribute("dateTo")
		Attribute("url")
		Attribute("comment")
		Attribute("rate")
		Attribute("totalHours")
		Attribute("entries")
	})

	View("tiny", func() {
		Attribute("id")
	})
})
