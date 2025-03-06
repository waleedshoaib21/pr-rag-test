import json
import re
from textblob import TextBlob

def analyze_code_comments(comments):
    """
    Uses NLP to analyze the sentiment of code comments.
    Identifies whether comments are constructive, neutral, or need improvement.
    """
    feedback = []
    
    for comment in comments:
        sentiment = TextBlob(comment).sentiment.polarity
        if sentiment > 0.2:
            feedback.append(f"✅ Positive comment: \"{comment}\"")
        elif sentiment < -0.2:
            feedback.append(f"⚠️ Needs improvement: \"{comment}\"")
        else:
            feedback.append(f"🔍 Neutral comment: \"{comment}\"")
    
    return feedback


def process_pull_request_with_ml(payload):
    """
    Processes a pull request event from GitHub Webhook.
    Extracts relevant information and applies ML-based analysis on PR comments.
    """
    if "pull_request" not in payload:
        return "❌ Not a valid PR event"

    pr_number = payload["pull_request"]["number"]
    repo_name = payload["repository"]["full_name"]
    pr_title = payload["pull_request"]["title"]
    pr_author = payload["pull_request"]["user"]["login"]
    changed_files = [file["filename"] for file in payload.get("pull_request", {}).get("files", [])]

    # Mocked PR comments (In a real scenario, fetch comments from GitHub API)
    pr_comments = [
        "This function looks great! Well optimized.",
        "Your variable names are unclear.",
        "Consider adding more docstrings to explain your logic.",
        "The indentation is wrong here, please fix it.",
        "Nice use of list comprehensions!"
    ]

    # Apply ML analysis to comments
    analyzed_comments = analyze_code_comments(pr_comments)

    # Construct ML-Based Review Summary
    review_summary = f"""
    🚀 **Machine Learning-Based PR Review for {repo_name}**
    **PR #{pr_number}:** {pr_title}
    **Author:** {pr_author}

    **Changed Files:**
    {json.dumps(changed_files, indent=2)}

    **Code Review Comments Analysis:**
    {'\n'.join(analyzed_comments)}

    ✅ Please review and consider improving the flagged comments.
    """

    return review_summary
