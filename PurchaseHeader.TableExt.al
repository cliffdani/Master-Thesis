tableextension 50200 "NCT Purchase Header" extends "Purchase Header"
{
    fields
    {
        // ---- Figure 1: custom header fields -------------------------------
        field(50100; "NCT Vorhabennr."; Code[20])
        {
            Caption = 'Vorhabennr.';
            DataClassification = CustomerContent;
            TableRelation = Job."No.";   // Project / Job. Delete this line if the number is typed manually.
        }
        field(50101; "NCT Unser Zeichen"; Text[50])
        {
            Caption = 'Unser Zeichen';
            DataClassification = CustomerContent;
        }
        field(50102; "NCT Ansprechp. Einkauf"; Code[20])
        {
            Caption = 'Ansprechpartner Einkauf';
            DataClassification = CustomerContent;
            TableRelation = "Salesperson/Purchaser".Code;
        }
        field(50103; "NCT Ansprechp. Technik"; Code[20])
        {
            Caption = 'Ansprechpartner Technik';
            DataClassification = CustomerContent;
            TableRelation = "Salesperson/Purchaser".Code;
        }

        // ---- Figures 2 & 7: the rich text stored on the document ----------
        field(50110; "NCT Header Text"; Blob)
        {
            Caption = 'Header Text';
            DataClassification = CustomerContent;
        }
        field(50111; "NCT Footer Text"; Blob)
        {
            Caption = 'Footer Text';
            DataClassification = CustomerContent;
        }
    }

    procedure NCTGetHeaderText() Html: Text
    var
        TypeHelper: Codeunit "Type Helper";
        InStr: InStream;
    begin
        CalcFields("NCT Header Text");
        if not "NCT Header Text".HasValue() then
            exit('');
        "NCT Header Text".CreateInStream(InStr, TextEncoding::UTF8);
        Html := TypeHelper.ReadAsTextWithSeparator(InStr, TypeHelper.LFSeparator());
    end;

    procedure NCTGetFooterText() Html: Text
    var
        TypeHelper: Codeunit "Type Helper";
        InStr: InStream;
    begin
        CalcFields("NCT Footer Text");
        if not "NCT Footer Text".HasValue() then
            exit('');
        "NCT Footer Text".CreateInStream(InStr, TextEncoding::UTF8);
        Html := TypeHelper.ReadAsTextWithSeparator(InStr, TypeHelper.LFSeparator());
    end;

    procedure NCTSetHeaderText(NewHtml: Text)
    var
        OutStr: OutStream;
    begin
        // CalcFields FIRST. A BLOB that has never been calculated is not flagged as
        // loaded, so the runtime leaves that column out of the UPDATE statement and
        // your change - especially clearing the text - is silently dropped.
        CalcFields("NCT Header Text");
        Clear("NCT Header Text");
        if NewHtml <> '' then begin
            "NCT Header Text".CreateOutStream(OutStr, TextEncoding::UTF8);
            OutStr.WriteText(NewHtml);
        end;
        Modify(true);
    end;

    procedure NCTSetFooterText(NewHtml: Text)
    var
        OutStr: OutStream;
    begin
        CalcFields("NCT Footer Text");
        Clear("NCT Footer Text");
        if NewHtml <> '' then begin
            "NCT Footer Text".CreateOutStream(OutStr, TextEncoding::UTF8);
            OutStr.WriteText(NewHtml);
        end;
        Modify(true);
    end;
}
