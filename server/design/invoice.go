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
	})

	Action("show", func() {
		Routing(GET("/:id"))
		Params(func() {
			Param("id", String, "Invoice ID")
		})
		Description("Get an invoice by id.")
		Response(OK, InvoiceMedia)
	})

	Action("update", func() {
		Routing(PUT("/:id"))
		Payload(InvoicePayload)
		Params(func() {
			Param("id", String, "Invoice ID")
		})
		Description("Update an invoice by id.")
		Response(OK, func() {
			Status(200)
			Media(InvoiceMedia, "tiny")
		})
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
	})

	Action("list", func() {
		Routing(GET("/list"))
		Description("Get all invoices")
		Response(OK, CollectionOf(InvoiceMedia))
	})

	Action("print", func() {
		Routing(GET("/print/:id"))
		Params(func() {
			Param("id", Integer, "Invoice ID")
		})
		Description("Print an invoice")
		Response(OK, "application/json")
	})
})

var InvoicePayload = Type("InvoicePayload", func() {
	Description("Invoice Description.")

	Attribute("id", Integer, "ID", func() {
		Metadata("struct:tag:datastore", "id,noindex")
		Metadata("struct:tag:json", "id,omitempty")
	})
	Attribute("title", String, "Invoice title", func() {
		Metadata("struct:tag:datastore", "title,noindex")
		Metadata("struct:tag:json", "title,omitempty")
	})
	Attribute("dateFrom", String, "Invoice date from", func() {
		Metadata("struct:tag:datastore", "dateFrom,noindex")
		Metadata("struct:tag:json", "dateFrom,omitempty")
	})
	Attribute("dateTo", String, "Invoice date to", func() {
		Metadata("struct:tag:datastore", "dateTo,noindex")
		Metadata("struct:tag:json", "dateTo,omitempty")
	})
	Attribute("url", String, "Invoice url", func() {
		Metadata("struct:tag:datastore", "url,noindex")
		Metadata("struct:tag:json", "url,omitempty")
	})
	Attribute("comment", String, "Invoice comment", func() {
		Metadata("struct:tag:datastore", "comment,noindex")
		Metadata("struct:tag:json", "comment,omitempty")
	})
	Attribute("rate", Number, "Invoice rate", func() {
		Metadata("struct:tag:datastore", "rate,noindex")
		Metadata("struct:tag:json", "rate,omitempty")
	})
	Attribute("totalHours", Number, "Invoice total hours", func() {
		Metadata("struct:tag:datastore", "totalHours,noindex")
		// Note that the following statement is needed b/c the json response was returned with
		// `TotalHours` in the payload which was not being correctly parsed into the client-side
		// model b/c Elm was expecting it to be camel-case `totalHours`!
		Metadata("struct:tag:json", "totalHours,omitempty")
	})

	Required("title", "dateFrom", "dateTo", "url", "comment", "rate", "totalHours")
})

var InvoiceMedia = MediaType("application/invoiceapi.invoiceentity", func() {
	Description("Invoice response")
	TypeName("InvoiceMedia")
	ContentType("application/json")
	Reference(InvoicePayload)

	Attributes(func() {
		Attribute("id")
		Attribute("title")
		Attribute("dateFrom")
		Attribute("dateTo")
		Attribute("url")
		Attribute("comment")
		Attribute("rate")
		Attribute("totalHours")

		Required("id", "title", "dateFrom", "dateTo", "url", "comment", "rate", "totalHours")
	})

	View("default", func() {
		Attribute("id")
		Attribute("title")
		Attribute("dateFrom")
		Attribute("dateTo")
		Attribute("url")
		Attribute("comment")
		Attribute("rate")
		Attribute("totalHours")
	})

	View("tiny", func() {
		Description("`tiny` is the view used to create new invoices.")
		Attribute("id")
	})
})
