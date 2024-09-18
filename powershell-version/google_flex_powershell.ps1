Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

function Show-AdvancedSearchForm {
    [System.Windows.Forms.Application]::EnableVisualStyles()

    $form = New-Object System.Windows.Forms.Form
    $form.Text = "Google Advanced Search"
    $form.Size = New-Object System.Drawing.Size(700, 750)
    $form.StartPosition = "CenterScreen"

    # Function to create and return a textbox control
    function CreateTextboxControl($labelText, $yPos) {
        $label = New-Object System.Windows.Forms.Label
        $label.Text = $labelText
        $label.AutoSize = $true
        $label.Location = New-Object System.Drawing.Point(10, $yPos)
        $form.Controls.Add($label)

        $textBox = New-Object System.Windows.Forms.TextBox
        $textBox.Location = New-Object System.Drawing.Point(200, $yPos)
        $textBox.Width = 450
        $form.Controls.Add($textBox)

        return $textBox
    }

    # Create TextBox controls for inputs
    $inputs = @{}
    $y = 20
    $labelTexts = @(
        "All these words (AND):", "This exact word or phrase:", "Any of these words (OR):", 
        "None of these words (NOT):", "Numbers ranging from:", "Numbers ranging to:", 
        "Site or domain:", "Terms appearing:", "File type:", "Related sites (URL):", 
        "Cached page (URL):", "Definition of:", "Info about (URL):", "In anchor text:", 
        "All in title:", "All in URL:", "All in text:", "Proximity term 1:", 
        "Proximity distance:", "Proximity term 2:", "Before date (YYYY-MM-DD):", 
        "After date (YYYY-MM-DD):"
    )

    foreach ($labelText in $labelTexts) {
        $inputs[$labelText] = CreateTextboxControl $labelText $y
        $y += 30
    }

    # Add Search button
    $searchButton = New-Object System.Windows.Forms.Button
    $searchButton.Text = "Search"
    $searchButton.Location = New-Object System.Drawing.Point(550, $y)
    $searchButton.Add_Click({
        # Build the search query
        $queryParts = @()

        foreach ($key in $inputs.Keys) {
            if ($inputs[$key].Text -ne "") {
                $queryParts += $inputs[$key].Text
            }
        }

        # Construct the search query string
        $query = [String]::Join(" ", $queryParts)
        $encodedQuery = [System.Web.HttpUtility]::UrlEncode($query)

        # Open the URL in the default web browser
        $searchUrl = "https://www.google.com/search?q=$encodedQuery"
        Start-Process $searchUrl
    })
    $form.Controls.Add($searchButton)

    # Show the form
    [void]$form.ShowDialog()
}

# Run the function
Show-AdvancedSearchForm
