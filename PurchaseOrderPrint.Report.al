report 50200 "NCT Purchase Order"
{
    Caption = 'Purchase Order';
    ApplicationArea = All;
    UsageCategory = None;                       // launched via Report Selection

    // A report MUST declare a layout, or you get
    // "Report 50200 does not have a valid layout."
    //
    // This project compiles with AL 17.0 (BC 2020 wave 2). The 'rendering' section
    // does not exist before BC 2022 wave 2 (v21), so use the RDLCLayout property.
    // Path is relative to the folder containing app.json.
    RDLCLayout = './Layouts/NCTPurchaseOrder.rdl';

    dataset
    {
        dataitem(Header; "Purchase Header")
        {
            DataItemTableView = where("Document Type" = const(Order));
            RequestFilterHeading = 'Purchase Order';

            // FIX 2 - "No. Printed" is deliberately NOT a filter field. A saved
            //         filter of 0 there is the classic cause of a zero-row dataset.
            RequestFilterFields = "No.", "Buy-from Vendor No.";

            column(CompanyName; CompanyInfo.Name) { }
            column(CompanyAddr1; CompanyAddr[1]) { }
            column(CompanyAddr2; CompanyAddr[2]) { }
            column(CompanyAddr3; CompanyAddr[3]) { }
            column(CompanyAddr4; CompanyAddr[4]) { }
            column(CompanyPhone; CompanyInfo."Phone No.") { }
            column(CompanyEMail; CompanyInfo."E-Mail") { }
            column(CompanyHomePage; CompanyInfo."Home Page") { }
            column(CompanyBankName; CompanyInfo."Bank Name") { }
            column(CompanyIBAN; CompanyInfo.IBAN) { }
            column(CompanySWIFT; CompanyInfo."SWIFT Code") { }
            column(CompanyVATRegNo; CompanyInfo."VAT Registration No.") { }
            column(CompanyPicture; CompanyInfo.Picture) { }

            column(BuyFromAddr1; BuyFromAddr[1]) { }
            column(BuyFromAddr2; BuyFromAddr[2]) { }
            column(BuyFromAddr3; BuyFromAddr[3]) { }
            column(BuyFromAddr4; BuyFromAddr[4]) { }
            column(BuyFromAddr5; BuyFromAddr[5]) { }
            column(BuyFromAddr6; BuyFromAddr[6]) { }

            column(DocumentNo; Header."No.") { }
            column(DocumentDate; Format(Header."Document Date")) { }
            column(VendorOrderNo; Header."Vendor Order No.") { }
            column(YourReference; Header."Your Reference") { }
            column(Vorhabennr; Header."NCT Vorhabennr.") { }
            column(UnserZeichen; Header."NCT Unser Zeichen") { }
            column(AnsprechpEinkauf; EinkaufName) { }
            column(AnsprechpEinkaufPhone; EinkaufPhone) { }
            column(AnsprechpEinkaufEMail; EinkaufEMail) { }
            column(AnsprechpTechnik; TechnikName) { }

            column(Zahlungsbedingungen; PaymentTermsText) { }
            column(Lieferbedingung; ShipmentMethodText) { }
            column(Lieferdatum; Format(Header."Expected Receipt Date")) { }

            column(HeaderTextHtml; HeaderTextHtml) { }
            column(FooterTextHtml; FooterTextHtml) { }

            column(CurrencyCode; CurrencyText) { }
            column(TotalExclVAT; Header.Amount) { }
            column(TotalVAT; Header."Amount Including VAT" - Header.Amount) { }
            column(TotalInclVAT; Header."Amount Including VAT") { }

            dataitem(Line; "Purchase Line")
            {
                DataItemLink = "Document Type" = field("Document Type"), "Document No." = field("No.");
                DataItemLinkReference = Header;
                DataItemTableView = sorting("Document Type", "Document No.", "Line No.");

                column(LineNo; Line."Line No.") { }
                column(LineItemNo; Line."No.") { }
                column(LineDescription; Line.Description) { }
                column(LineDescription2; Line."Description 2") { }
                column(LineQuantity; Line.Quantity) { }
                column(LineUoM; Line."Unit of Measure Code") { }
                column(LineUnitCost; Line."Direct Unit Cost") { }
                column(LineDiscountPct; Line."Line Discount %") { }
                column(LineAmount; Line."Line Amount") { }
                column(LineReceiptDate; Format(Line."Expected Receipt Date")) { }

                trigger OnPreDataItem()
                begin
                    Line.SetFilter(Type, '<>%1', Line.Type::" ");
                end;
            }

            trigger OnPreDataItem()
            begin
                CompanyInfo.Get();
                FormatAddress.Company(CompanyAddr, CompanyInfo);
                // NOTE: no CalcFields on CompanyInfo.Picture - it is a Media field
                // in current BC and CalcFields on Media is a compile error.
            end;

            trigger OnAfterGetRecord()
            var
                SalespersonPurchaser: Record "Salesperson/Purchaser";
                PaymentTerms: Record "Payment Terms";
                ShipmentMethod: Record "Shipment Method";
                GLSetup: Record "General Ledger Setup";
            begin
                CurrReport.Language := LanguageMgt.GetLanguageIdOrDefault(Header."Language Code");

                Header.CalcFields(Amount, "Amount Including VAT");

                // FIX 3 - CalcFields before reading the BLOBs, or they come back empty
                Header.CalcFields("NCT Header Text", "NCT Footer Text");
                HeaderTextHtml := Header.NCTGetHeaderText();
                FooterTextHtml := Header.NCTGetFooterText();

                // Optional one-off override chosen on the request page
                if HeaderTemplateCode <> '' then
                    HeaderTextHtml := GetTemplateHtml(HeaderTemplateCode);
                if FooterTemplateCode <> '' then
                    FooterTextHtml := GetTemplateHtml(FooterTemplateCode);

                FormatAddress.PurchHeaderBuyFrom(BuyFromAddr, Header);

                CurrencyText := Header."Currency Code";
                if CurrencyText = '' then
                    if GLSetup.Get() then
                        CurrencyText := GLSetup."LCY Code";

                Clear(EinkaufName);
                Clear(EinkaufPhone);
                Clear(EinkaufEMail);
                if SalespersonPurchaser.Get(Header."NCT Ansprechp. Einkauf") then begin
                    EinkaufName := SalespersonPurchaser.Name;
                    EinkaufPhone := SalespersonPurchaser."Phone No.";
                    EinkaufEMail := SalespersonPurchaser."E-Mail";
                end;

                Clear(TechnikName);
                if SalespersonPurchaser.Get(Header."NCT Ansprechp. Technik") then
                    TechnikName := SalespersonPurchaser.Name;

                PaymentTermsText := Header."Payment Terms Code";
                if PaymentTerms.Get(Header."Payment Terms Code") then begin
                    PaymentTerms.TranslateDescription(PaymentTerms, Header."Language Code");
                    PaymentTermsText := PaymentTerms.Description;
                end;

                ShipmentMethodText := Header."Shipment Method Code";
                if ShipmentMethod.Get(Header."Shipment Method Code") then
                    ShipmentMethodText := ShipmentMethod.Description;
            end;
        }
    }

    requestpage
    {
        // FIX 4 - stale saved filters cannot survive between runs
        SaveValues = false;

        layout
        {
            area(Content)
            {
                group(TextOptions)
                {
                    Caption = 'Header and Footer Text';

                    field(HeaderTemplateCodeCtrl; HeaderTemplateCode)
                    {
                        ApplicationArea = All;
                        Caption = 'Override Header Template';
                        ToolTip = 'Leave blank to print the header text saved on the order.';
                        TableRelation = "NCT Doc Text Template".Code;
                    }
                    field(FooterTemplateCodeCtrl; FooterTemplateCode)
                    {
                        ApplicationArea = All;
                        Caption = 'Override Footer Template';
                        ToolTip = 'Leave blank to print the footer text saved on the order.';
                        TableRelation = "NCT Doc Text Template".Code;
                    }
                }
            }
        }
    }

    var
        CompanyInfo: Record "Company Information";
        FormatAddress: Codeunit "Format Address";
        LanguageMgt: Codeunit Language;
        CompanyAddr: array[8] of Text[100];
        BuyFromAddr: array[8] of Text[100];
        HeaderTextHtml: Text;
        FooterTextHtml: Text;
        EinkaufName: Text[100];
        EinkaufPhone: Text[30];
        EinkaufEMail: Text[80];
        TechnikName: Text[100];
        PaymentTermsText: Text[100];
        ShipmentMethodText: Text[100];
        CurrencyText: Code[10];
        HeaderTemplateCode: Code[20];
        FooterTemplateCode: Code[20];

    local procedure GetTemplateHtml(TemplateCode: Code[20]): Text
    var
        Template: Record "NCT Doc Text Template";
    begin
        if Template.Get(TemplateCode) then
            exit(Template.GetTemplateText());
        exit('');
    end;
}
