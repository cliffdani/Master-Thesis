page 50201 "NCT Doc Text Template Card"
{
    Caption = 'Document Text Template';
    PageType = Card;
    ApplicationArea = All;
    SourceTable = "NCT Doc Text Template";

    layout
    {
        area(Content)
        {
            group(General)
            {
                field("Code"; Rec."Code") { ApplicationArea = All; }
                field(Description; Rec.Description) { ApplicationArea = All; }
                field(Position; Rec.Position) { ApplicationArea = All; }
                field("Language Code"; Rec."Language Code") { ApplicationArea = All; }
                field("Starting Date"; Rec."Starting Date") { ApplicationArea = All; }
                field("Ending Date"; Rec."Ending Date") { ApplicationArea = All; }
            }

            // IMPORTANT: a RichContent field must be ALONE in its own root-level group.
            group(TextGroup)
            {
                Caption = 'Text';

                field(TemplateText; TemplateTextVar)
                {
                    ApplicationArea = All;
                    Caption = 'Text';
                    ShowCaption = false;
                    MultiLine = true;
                    ExtendedDatatype = RichContent;

                    trigger OnValidate()
                    begin
                        Rec.SetTemplateText(TemplateTextVar);
                    end;
                }
            }
        }
    }

    var
        TemplateTextVar: Text;

    trigger OnAfterGetRecord()
    begin
        TemplateTextVar := Rec.GetTemplateText();
    end;

    trigger OnNewRecord(BelowxRec: Boolean)
    begin
        Clear(TemplateTextVar);
    end;
}
