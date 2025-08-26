GitHub Dependency Confusion Scanner

This tool automates the discovery of potential dependency confusion vulnerabilities in package.json files across all repositories in a given GitHub organization.

It uses the GitHub CLI (gh), confused, jq, and curl to:
	1.	Enumerate repositories in a GitHub organization.
	2.	Locate all package.json files.
	3.	Fetch the raw package.json from GitHub.
	4.	Run confused to check for packages that do not exist in public registries (potential confusion risk).
	5.	Output results in a clear, tabular format.

⸻

🔧 Features
	•	Enumerates up to 1000 repositories per organization.
	•	Detects all package.json files recursively.
	•	Identifies potential dependency confusion risks.
	•	Generates output in an easy-to-read format with repository name, file path, and raw GitHub URL.
	•	Handles missing branches gracefully (defaults to main).
	•	Cleans up temporary files automatically.

⸻

🚀 Installation

Requirements

Make sure you have the following installed:
	•	GitHub CLI (gh)
	•	jq
	•	curl
	•	confused

Install them on macOS/Linux:

brew install gh jq curl

https://github.com/visma-prodsec/confused -> Install from this.

Login with GitHub CLI:

gh auth login


⸻

📌 Usage

Run the script with a GitHub organization name:

./dep.sh <github-org>

Example:

./dep.sh my-company


⸻

📊 Output Example

[*] Enumerating repos for my-company ...
  -> Scanning my-company/repo1 (main)
  -> Scanning my-company/repo2 (master)
[*] Found 3 package.json files.

==== RESULTS ====
STATUS                  repo                  path                raw_url
================================================================================================================
PUBLICLY_ACCESSIBLE     my-company/repo1      package.json        https://raw.githubusercontent.com/my-company/repo1/main/package.json
POTENTIAL_DEP_CONFUSION my-company/repo2      src/package.json    https://raw.githubusercontent.com/my-company/repo2/master/src/package.json

	•	PUBLICLY_ACCESSIBLE → All dependencies exist in public registries.
	•	POTENTIAL_DEP_CONFUSION → Some dependencies are missing from public registries (possible confusion risk).
	•	ERROR → Failed to fetch or scan the file.

⸻

⚠️ Disclaimer

This tool is provided for security testing and educational purposes only.
Do not run it against organizations or repositories you do not own or have explicit permission to test.
