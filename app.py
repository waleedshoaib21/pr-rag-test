import json

def process_pull_request(payload):
    """
    Processes a pull request event from GitHub Webhook.
    Extracts relevant information and simulates a PR review.
    """
    if "pull_request" not in payload:
        return "❌ Not a valid PR event"

    pr_number = payload["pull_request"]["number"]
    repo_name = payload["repository"]["full_name"]
    pr_title = payload["pull_request"]["title"]
    pr_author = payload["pull_request"]["user"]["login"]
    changed_files = [file["filename"] for file in payload.get("pull_request", {}).get("files", [])]

    # Simulated PR Review Logic
    review_feedback = []
    
    for file in changed_files:
        if file.endswith(".py"):
            review_feedback.append(f"✅ `{file}` looks like a Python file. Consider checking for PEP8 compliance.")
        elif file.endswith(".js"):
            review_feedback.append(f"✅ `{file}` is a JavaScript file. Ensure best practices for async handling.")
        else:
            review_feedback.append(f"🔍 `{file}` was modified. Please review manually.")

    # Construct Review Summary
    review_summary = f"""
    🚀 **Pull Request Review for {repo_name}**
    **PR #{pr_number}:** {pr_title}
    **Author:** {pr_author}

    **Changed Files:**
    {json.dumps(changed_files, indent=2)}

    **Review Feedback:**
    {'\n'.join(review_feedback)}

    ✅ Please review and provide your comments.
    """

    return review_summary
