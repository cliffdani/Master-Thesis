pageextension 50200 "NCT Purchase Order" extends "Purchase Order"
{
    layout
    {
        // ---- Figure 1: custom fields on the General FastTab ---------------
        addlast(General)
        {
            field("NCT Vorhabennr."; Rec."NCT Vorhabennr.") { ApplicationArea = All; }
            field("NCT Unser Zeichen"; Rec."NCT Unser Zeichen") { ApplicationArea = All; }
            field("NCT Ansprechp. Einkauf"; Rec."NCT Ansprechp. Einkauf") { ApplicationArea = All; }
            field("NCT Ansprechp. Technik"; Rec."NCT Ansprechp. Technik") { ApplicationArea = All; }
        }

        // ---- Figures 2 & 7: two rich text editors -------------------------
        // A RichContent field MUST be the only control in its FastTab group.
        addlast(content)
        {
            group(NCTHeaderTextGroup)
            {
                Caption = 'Header Text (print)';

                field(NCTHeaderText; NCTHeaderTextVar)
                {
                    ApplicationArea = All;
                    Caption = 'Header Text';
                    ShowCaption = false;
                    MultiLine = true;
                    ExtendedDatatype = RichContent;

                    trigger OnValidate()
                    begin
                        Rec.NCTSetHeaderText(NCTHeaderTextVar);
                        CurrPage.SaveRecord();
                    end;
                }
            }

            group(NCTFooterTextGroup)
            {
                Caption = 'Footer Text (print)';

                field(NCTFooterText; NCTFooterTextVar)
                {
                    ApplicationArea = All;
                    Caption = 'Footer Text';
                    ShowCaption = false;
                    MultiLine = true;
                    ExtendedDatatype = RichContent;

                    trigger OnValidate()
                    begin
                        Rec.NCTSetFooterText(NCTFooterTextVar);
                        CurrPage.SaveRecord();
                    end;
                }
            }
        }
    }

    actions
    {
        addlast(Category_Process)
        {
            actionref(NCTInsertHeaderTemplate_Promoted; NCTInsertHeaderTemplate) { }
            actionref(NCTInsertFooterTemplate_Promoted; NCTInsertFooterTemplate) { }
        }

        addlast(Processing)
        {
            group(NCTTextTemplates)
            {
                Caption = 'Text Templates';
                Image = Text;

                action(NCTInsertHeaderTemplate)
                {
                    ApplicationArea = All;
                    Caption = 'Insert Header Template';
                    Image = Text;

                    trigger OnAction()
                    var
                        DocTextMgt: Codeunit "NCT Doc Text Mgt.";
                        NewHtml: Text;
                    begin
                        if DocTextMgt.SelectTemplate("NCT Doc Text Position"::Header, Rec."Language Code", NewHtml) then begin
                            NCTHeaderTextVar := DocTextMgt.AppendHtml(NCTHeaderTextVar, NewHtml);
                            Rec.NCTSetHeaderText(NCTHeaderTextVar);
                            Rec.Get(Rec."Document Type", Rec."No.");
                            NCTHeaderTextVar := Rec.NCTGetHeaderText();
                            CurrPage.Update(false);
                        end;
                    end;
                }

                action(NCTInsertFooterTemplate)
                {
                    ApplicationArea = All;
                    Caption = 'Insert Footer Template';
                    Image = Text;

                    trigger OnAction()
                    var
                        DocTextMgt: Codeunit "NCT Doc Text Mgt.";
                        NewHtml: Text;
                    begin
                        if DocTextMgt.SelectTemplate("NCT Doc Text Position"::Footer, Rec."Language Code", NewHtml) then begin
                            NCTFooterTextVar := DocTextMgt.AppendHtml(NCTFooterTextVar, NewHtml);
                            Rec.NCTSetFooterText(NCTFooterTextVar);
                            Rec.Get(Rec."Document Type", Rec."No.");
                            NCTFooterTextVar := Rec.NCTGetFooterText();
                            CurrPage.Update(false);
                        end;
                    end;
                }

                action(NCTOpenTemplates)
                {
                    ApplicationArea = All;
                    Caption = 'Manage Text Templates';
                    Image = TextFile;
                    RunObject = page "NCT Doc Text Templates";
                }
            }
        }
    }

    var
        NCTHeaderTextVar: Text;
        NCTFooterTextVar: Text;

    trigger OnAfterGetCurrRecord()
    begin
        NCTHeaderTextVar := Rec.NCTGetHeaderText();
        NCTFooterTextVar := Rec.NCTGetFooterText();
    end;
}
