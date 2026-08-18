page 50200 "NCT Doc Text Templates"
{
    Caption = 'Document Text Templates';
    PageType = List;
    ApplicationArea = All;
    UsageCategory = Administration;
    SourceTable = "NCT Doc Text Template";
    CardPageId = "NCT Doc Text Template Card";
    Editable = false;

    layout
    {
        area(Content)
        {
            repeater(General)
            {
                field("Code"; Rec."Code") { ApplicationArea = All; }
                field(Description; Rec.Description) { ApplicationArea = All; }
                field(Position; Rec.Position) { ApplicationArea = All; }
                field("Language Code"; Rec."Language Code") { ApplicationArea = All; }
                field("Starting Date"; Rec."Starting Date") { ApplicationArea = All; }
                field("Ending Date"; Rec."Ending Date") { ApplicationArea = All; }
            }
        }
    }
}
