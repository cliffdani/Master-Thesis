codeunit 50200 "NCT Doc Text Mgt."
{
    /// <summary>
    /// Opens the template list filtered on Header or Footer, lets the user pick one,
    /// and returns its HTML. Returns false if the user cancels.
    /// </summary>
    procedure SelectTemplate(Position: Enum "NCT Doc Text Position"; LanguageCode: Code[10]; var Html: Text): Boolean
    var
        Template: Record "NCT Doc Text Template";
        TemplateList: Page "NCT Doc Text Templates";
    begin
        Template.SetFilter(Position, '%1|%2', Position, Position::Both);
        if LanguageCode <> '' then
            Template.SetFilter("Language Code", '%1|%2', LanguageCode, '');
        Template.SetFilter("Starting Date", '%1|<=%2', 0D, WorkDate());
        Template.SetFilter("Ending Date", '%1|>=%2', 0D, WorkDate());

        TemplateList.SetTableView(Template);
        TemplateList.LookupMode(true);
        if TemplateList.RunModal() <> Action::LookupOK then
            exit(false);

        TemplateList.GetRecord(Template);
        Html := Template.GetTemplateText();
        exit(true);
    end;

    /// <summary>Appends new HTML below existing HTML.</summary>
    procedure AppendHtml(ExistingHtml: Text; NewHtml: Text): Text
    begin
        if ExistingHtml = '' then
            exit(NewHtml);
        if NewHtml = '' then
            exit(ExistingHtml);
        exit(ExistingHtml + '<p></p>' + NewHtml);
    end;
}
