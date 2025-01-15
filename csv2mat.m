function deneme()
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

function saveMATFile(fig)
    % Get data from figure
    if isempty(fig.UserData)
        uialert(fig, 'No data to save. Load a CSV file first.', 'Error');
        return;
    end

    % Prompt user to select save location
    [file, path] = uiputfile('*.mat', 'Save MAT File');
    if isequal(file, 0)
        return;
    end

    % Save data to MAT file
    fullPath = fullfile(path, file);
    try
        data = fig.UserData;

        % Extract time column (assume first column is time)
        timeVar = data.(data.Properties.VariableNames{1});
        if iscell(timeVar) || isstring(timeVar)
            % Convert string or cell to numeric if possible
            timeVar = str2double(timeVar);
        end
        if any(isnan(timeVar))
            error('Time column contains invalid (non-numeric) values.');
        end

        % Convert table to struct and timeseries
        dataStruct = struct(); % Initialize struct
        dataStruct.TimeSeries = struct();

        for i = 2:width(data)
            varName = matlab.lang.makeValidName(data.Properties.VariableNames{i}); % Ensure valid names
            % Check if column data is numeric
            columnData = data.(data.Properties.VariableNames{i});
            if isnumeric(columnData)
                dataStruct.TimeSeries.(varName) = timeseries(columnData, timeVar);
            else
                warning('Column "%s" is not numeric and will be skipped.', varName);
            end
        end

        % Save the struct to MAT file
        save(fullPath, 'dataStruct');

        % Update status
        statusLabel = findobj(fig, 'Tag', 'StatusLabel');
        statusLabel.Text = sprintf('Saved MAT file: %s', file);
    catch ME
        uialert(fig, sprintf('Error saving file: %s', ME.message), 'Error');
    end
end
