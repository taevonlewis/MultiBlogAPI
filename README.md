# MultiBlogAPI

MultiBlogAPI is a command-line tool that allows you to post your Markdown-formatted articles to multiple blogging platforms simultaneously, including Medium, Dev.to, and Hashnode. It streamlines the process of publishing content across platforms, handling authentication tokens securely using the system’s Keychain, and providing an interactive experience for managing your settings.

## Features

	•	Multi-Platform Posting: Publish your articles to Medium, Dev.to, and Hashnode with a single command.
	•	Secure Token Storage: Authentication tokens are securely stored in the Keychain, ensuring they are kept safe between sessions.
	•	Interactive Prompts: The tool prompts for necessary inputs if they are not provided via command-line arguments or saved settings.
	•	Settings Management: Save frequently used settings like the Markdown file path and Hashnode host for future use. Easily manage and delete saved tokens and settings.
	•	Input Validation: Validates user inputs to prevent errors during execution.
	•	Help and Usage Information: Provides helpful usage information with the --help argument.

## Prerequisites

	•	Operating System: macOS
	•	Swift Compiler: Swift 5.3 or higher is required to compile the source code.
	•	Command-Line Tools: Terminal or command prompt access.

## Installation

### Option 1: Download the Executable

	1.	Download the Executable:
	•	Visit the Releases page of this repository.
	•	Download the latest MultiBlogAPI.zip file for your operating system.
	•	Extract the contents to a desired location.
	2.	Make the Executable Runnable (if necessary):

`chmod +x MultiBlogAPI`



### Option 2: Build from Source

    1. Clone the Repository:

`git clone https://github.com/yourusername/MultiBlogAPI.git`


	2.	Navigate to the Directory:

`cd MultiBlogAPI`


	3.	Compile the Source Code:

`swiftc main.swift -o MultiBlogAPI`



## Usage

You can run the tool either by double-clicking the executable (which will open a terminal window) or via the command line.

Running the Tool

### Option 1: Double-Click the Executable

	•	Double-click the MultiBlogAPI executable file.
	•	The tool will open a terminal window and begin prompting you for any necessary inputs.

### Option 2: Command-Line Execution

	•	Open a terminal window.
	•	Navigate to the directory containing the MultiBlogAPI executable.
	•	Run the tool with optional arguments:

`./MultiBlogAPI [options]`



### Command-Line Arguments

You can provide the following command-line arguments to streamline the posting process:

	•	--title: The title of your article.
	•	--file: The path to your Markdown file.
	•	--host: Your Hashnode blog domain (e.g., yourblog.hashnode.dev).
	•	--help: Display usage information.

### Example:

```bash
./MultiBlogAPI --title "Exploring Swift 5.5" --file /path/to/article.md --host yourblog.hashnode.dev
```

### Interactive Prompts

If you omit any arguments, the tool will interactively prompt you for the required information. For example:

```bash
Enter the article title:
> My Awesome Article
Enter the markdown file path:
> /path/to/article.md
Enter the host (Hashnode blog domain):
> myblog.hashnode.dev
```

## Token Management

### Providing Tokens

The tool requires API tokens to post to the platforms. If you haven’t provided tokens yet, the tool will prompt you to enter them:

```bash
Token for MediumToken not found. Please enter your MediumToken token:
> your-medium-token
Do you want to save this token in the Keychain for future use? (yes/no)
> yes
Token saved in Keychain.
```

### Deleting Tokens

At the start of the tool, if tokens or settings are found in the Keychain, you will be given the option to delete them:

```bash
Saved tokens and settings found in Keychain:
1. MediumToken
2. DevToken
3. HashnodeToken
4. MarkdownFilePath
5. Host
Do you want to delete any of them before proceeding? (yes/no)
> yes
Enter the numbers of the items you want to delete, separated by commas (e.g., 1,3):
> 2,5
Deleted DevToken from Keychain.
Deleted Host from Keychain.
```

### Saving Settings

When you provide the Markdown file path and host, you will be asked if you want to save these values for future use:

```bash
Do you want to save this value in the Keychain for future use? (yes/no)
> yes
Value saved in Keychain.
```

### Input Validation

	•	The tool checks if the provided Markdown file exists.
	•	Ensures that required inputs are not empty.
	•	Provides error messages and waits for the user to press Enter before exiting, allowing you to read any issues.

### Exiting the Tool

After the posting process is complete or if an error occurs, the tool will prompt you to press Enter before exiting:

`Press Enter to exit...`

## Examples

### Posting with All Arguments Provided

```bash
./MultiBlogAPI --title "Understanding Async/Await in Swift" --file ~/Documents/async-await.md --host swiftblog.hashnode.dev
```

### Posting and Prompting for Missing Arguments

```bash
./MultiBlogAPI--title "Swift Concurrency Overview"
```

The tool will prompt you for the missing Markdown file path and host.

### Displaying Help Information

`./MultiBlogAPI --help`

Output:

```bash
Usage:
./MultiBlogAPI --title "Your Article Title" --file /path/to/article.md --host yourblog.hashnode.dev
```
```bash
Options:
--title    The title of the article.
--file     The path to the markdown file containing the article content.
--host     Your Hashnode blog domain (e.g., yourblog.hashnode.dev).
--help     Show this help message.
```

If you omit any arguments, the tool will prompt you to enter them.

## Supported Platforms

	•	Medium
	•	Dev.to
	•	Hashnode

## Security and Privacy

	•	Keychain Storage: The tool uses the system’s Keychain to securely store your API tokens and settings.
	•	Token Management: You have full control over your tokens and can delete them at any time through the tool’s interface.
	•	Data Handling: The tool does not transmit your tokens or data to any third-party servers except for the purposes of authenticating with the blogging platforms you choose to post to.

## Troubleshooting

	•	Invalid Token Errors: Ensure that your API tokens are correct. If you’ve regenerated your tokens on the respective platforms, delete the saved tokens from the Keychain and re-enter them when prompted.
	•	Markdown File Not Found: Verify that the path to your Markdown file is correct and that the file exists.
	•	Network Issues: Ensure you have a stable internet connection when using the tool.
