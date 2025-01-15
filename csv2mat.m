function csv2mat()
    % Main GUI figure
    fig = uifigure('Name', 'CSV to AT Converter', 'Position', [100, 100, 600, 400]);

    % File selection button
    uilabel(fig, 'Text', 'Select a CSV file:', 'Position', [20, 350, 120, 22]);
    btnLoad = uibutton(fig, 'push', 'Text', 'Load CSV', 'Position', [140, 350, 100, 22], ...
        'ButtonPushedFcn', @(btn, event) loadCSVFile(fig));

    % File preview table
    uitable(fig, 'Tag', 'PreviewTable', 'Position', [20, 150, 560, 180]);

    % Save button
    uilabel(fig, 'Text', 'Save as MAT file:', 'Position', [20, 100, 120, 22]);
    btnSave = uibutton(fig, 'push', 'Text', 'Save MAT', 'Position', [140, 100, 100, 22], ...
        'ButtonPushedFcn', @(btn, event) saveMATFile(fig));

    % Status label
    uilabel(fig, 'Text', '', 'Tag', 'StatusLabel', 'Position', [20, 50, 560, 22], ...
        'HorizontalAlignment', 'left');
end

function loadCSVFile(fig)
    % Prompt user to select a CSV file
    [file, path] = uigetfile('*.csv', 'Select a CSV File');
    if isequal(file, 0)
        return;
    end

    % Read CSV file
    fullPath = fullfile(path, file);
    try
        data = readtable(fullPath);
        % Display data in the table
        table = findobj(fig, 'Tag', 'PreviewTable');
        table.Data = data;
        table.ColumnName = data.Properties.VariableNames;

        % Store data in app figure for later use
        fig.UserData = data;

        % Update status
        statusLabel = findobj(fig, 'Tag', 'StatusLabel');
        statusLabel.Text = sprintf('Loaded file: %s', file);
    catch ME
        uialert(fig, sprintf('Error loading file: %s', ME.message), 'Error');
    end
end