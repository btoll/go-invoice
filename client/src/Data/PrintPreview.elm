module Data.PrintPreview exposing (PrintPreview, newPrintPreview)

import Data.Company exposing (Company)
import Data.Invoice exposing (Invoice)


type alias PrintPreview =
    { company : Company
    , invoice : Invoice
    }


newPrintPreview : PrintPreview
newPrintPreview =
    { company = Data.Company.new
    , invoice = Data.Invoice.new
    }


