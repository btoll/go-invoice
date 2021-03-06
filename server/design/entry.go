package design

import (
	. "github.com/goadesign/goa/design"
	. "github.com/goadesign/goa/design/apidsl"
)

var _ = Resource("Entry", func() {
	BasePath("/entry")
	Description("Describes an entry.")

	Action("create", func() {
		Routing(POST("/"))
		Description("Create a new entry.")
		Payload(EntryPayload)
		Response(OK, EntryMedia)
	})

	Action("show", func() {
		Routing(GET("/:id"))
		Params(func() {
			Param("id", Integer, "Entry ID")
		})
		Description("Get an entry by id.")
		Response(OK, EntryMedia)
	})

	Action("update", func() {
		Routing(PUT("/:id"))
		Payload(EntryPayload)
		Params(func() {
			Param("id", Integer, "Entry ID")
		})
		Description("Update an entry by id.")
		Response(OK, func() {
			Status(200)
			Media(EntryMedia, "tiny")
		})
	})

	Action("delete", func() {
		Routing(DELETE("/:id"))
		Params(func() {
			Param("id", Integer, "Entry ID")
		})
		Description("Delete an entry by id.")
		Response(OK, func() {
			Status(200)
			Media(EntryMedia, "tiny")
		})
	})

	Action("list", func() {
		Routing(GET("/list/:invoice_id"))
		Params(func() {
			Param("invoice_id", Integer, "Invoice ID")
		})
		Description("Get all entrys")
		Response(OK, CollectionOf(EntryMedia))
	})
})

var EntryPayload = Type("EntryPayload", func() {
	Description("Entry Description.")

	Attribute("id", Integer, "ID", func() {
		Metadata("struct:tag:datastore", "id,noindex")
		Metadata("struct:tag:json", "id")
	})
	Attribute("invoice_id", Integer, "Invoice ID (foreign key)", func() {
		Metadata("struct:tag:datastore", "invoice_id,noindex")
		Metadata("struct:tag:json", "invoice_id")
	})
	Attribute("title", String, "Entry title", func() {
		Metadata("struct:tag:datastore", "title,noindex")
		Metadata("struct:tag:json", "title")
	})
	Attribute("date", String, "Entry date", func() {
		Metadata("struct:tag:datastore", "date,noindex")
		Metadata("struct:tag:json", "date")
	})
	Attribute("reference", ArrayOf(String), "Entry reference", func() {
		Metadata("struct:tag:datastore", "reference,noindex")
		Metadata("struct:tag:json", "reference")
	})
	Attribute("notes", String, "Entry notes", func() {
		Metadata("struct:tag:datastore", "notes,noindex")
		Metadata("struct:tag:json", "notes")
	})
	Attribute("hours", Number, "Entry hours", func() {
		Metadata("struct:tag:datastore", "hours,noindex")
		Metadata("struct:tag:json", "hours")
	})

	Required("invoice_id", "title", "date", "reference", "notes", "hours")
})

var EntryMedia = MediaType("application/entryapi.entryentity", func() {
	Description("Entry response")
	TypeName("EntryMedia")
	ContentType("application/json")
	Reference(EntryPayload)

	Attributes(func() {
		Attribute("id")
		Attribute("invoice_id")
		Attribute("title")
		Attribute("date")
		Attribute("reference", ArrayOf(String))
		Attribute("notes")
		Attribute("hours")

		Required("id", "invoice_id", "title", "date", "reference", "notes", "hours")
	})

	View("default", func() {
		Attribute("id")
		Attribute("invoice_id")
		Attribute("title")
		Attribute("date")
		Attribute("reference")
		Attribute("notes")
		Attribute("hours")
	})

	View("tiny", func() {
		Description("`tiny` is the view used to create new entrys.")
		Attribute("id")
	})
})
