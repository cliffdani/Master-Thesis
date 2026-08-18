table 50200 "NCT Doc Text Template"
{
    Caption = 'Document Text Template';
    DataClassification = CustomerContent;
    LookupPageId = "NCT Doc Text Templates";
    DrillDownPageId = "NCT Doc Text Templates";

    fields
    {
        field(1; "Code"; Code[20])
        {
            Caption = 'Code';
            NotBlank = true;
        }
        field(2; Description; Text[100])
        {
            Caption = 'Description';
        }
        field(3; Position; Enum "NCT Doc Text Position")
        {
            Caption = 'Position';
        }
        field(4; "Language Code"; Code[10])
        {
            Caption = 'Language Code';
            TableRelation = Language;
        }
        field(5; "Template Text"; Blob)
        {
            Caption = 'Text';
        }
        field(6; "Starting Date"; Date)
        {
            Caption = 'Starting Date';
        }
        field(7; "Ending Date"; Date)
        {
            Caption = 'Ending Date';
        }
    }

    keys
    {
        key(PK; "Code") { Clustered = true; }
    }

    fieldgroups
    {
        fieldgroup(DropDown; "Code", Description, Position) { }
    }

    /// <summary>Returns the stored template as HTML text.</summary>
    procedure GetTemplateText() Html: Text
    var
        TypeHelper: Codeunit "Type Helper";
        InStr: InStream;
    begin
        CalcFields("Template Text");
        if not "Template Text".HasValue() then
            exit('');
        "Template Text".CreateInStream(InStr, TextEncoding::UTF8);
        Html := TypeHelper.ReadAsTextWithSeparator(InStr, TypeHelper.LFSeparator());
    end;

    /// <summary>Stores HTML text in the template and saves the record.</summary>
    procedure SetTemplateText(NewHtml: Text)
    var
        OutStr: OutStream;
    begin
        Clear("Template Text");
        if NewHtml <> '' then begin
            "Template Text".CreateOutStream(OutStr, TextEncoding::UTF8);
            OutStr.WriteText(NewHtml);
        end;
        Modify(true);
    end;
}
