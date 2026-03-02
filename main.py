import os
import sys
import importlib.util
import subprocess

# Function to load .env file
def load_env(env_path):
    if not os.path.exists(env_path):
        return
    with open(env_path, 'r') as f:
        for line in f:
            line = line.strip()
            if line and not line.startswith('#'):
                key, value = line.split('=', 1)
                os.environ[key] = value

# Load .env variables
# Check in the script's directory (pipeline_a) and then the workspace root
load_env(os.path.join(os.path.dirname(__file__), '.env'))
load_env(os.path.join(os.path.dirname(os.path.dirname(__file__)), '.env')) # Workspace root

# Dynamically load config.py
config_path = os.path.join(os.path.dirname(__file__), 'config.py')
spec = importlib.util.spec_from_file_location("config", config_path)
config = importlib.util.module_from_spec(spec)
sys.modules[spec.name] = config
spec.loader.exec_module(config)

def generate_article(topic, affiliate_id):
    # Simplified dummy content generation
    title = f"더미 콘텐츠: {topic}"
    intro = f"이것은 {topic}에 대한 매우 간단한 더미 소개입니다."
    feature1 = "더미 특징 1"
    feature2 = "더미 특징 2"
    feature3 = "더미 특징 3"
    benefits = "이 더미 콘텐츠는 아무런 실제 정보도 담고 있지 않습니다."
    conclusion = "여기서 더미 콘텐츠는 끝납니다."
    
    # Generic Coupang search link with affiliate ID
    product_search_query = topic.replace(" ", "+")
    affiliate_link = f"https://www.coupang.com/np/search?q={product_search_query}&channel=user_input&listSize=30&isInitialSearch=Y&source=search&memberID={affiliate_id}"

    template_path = os.path.join(os.path.dirname(__file__), 'templates', 'article.md')
    with open(template_path, 'r', encoding='utf-8') as f:
        template = f.read()

    article_content = template.format(
        title=title,
        intro=intro,
        feature1=feature1,
        feature2=feature2,
        feature3=feature3,
        benefits=benefits,
        conclusion=conclusion,
        affiliate_link=affiliate_link
    )
    return title, article_content

def run_git_command(command, cwd):
    result = subprocess.run(command, cwd=cwd, capture_output=True, text=True, shell=True)
    if result.returncode != 0:
        print(f"Git command failed: {command}")
        print(f"Stdout: {result.stdout}")
        print(f"Stderr: {result.stderr}")
        raise Exception(f"Git command failed: {command}")
    return result.stdout

if __name__ == "__main__":
    if not config.KEYWORDS:
        print("Error: No keywords defined in config.py")
        sys.exit(1)

    # Get affiliate ID from environment variables (loaded from .env)
    affiliate_id = os.environ.get('COUPANG_AFFILIATE_ID')
    if not affiliate_id:
        print("Error: COUPANG_AFFILIATE_ID is not set in .env file or environment variables.")
        sys.exit(1)

    # Use only the first keyword for simplified content generation
    target_keyword = config.KEYWORDS[0]
    
    article_title, generated_markdown = generate_article(target_keyword, affiliate_id)

    output_dir = os.path.join(os.path.dirname(__file__), 'output')
    os.makedirs(output_dir, exist_ok=True)
    
    # Sanitize title for filename
    filename = f"{article_title.replace(' ', '_').replace('/', '_')}.md"
    output_filepath = os.path.join(output_dir, filename)

    with open(output_filepath, 'w', encoding='utf-8') as f:
        f.write(generated_markdown)
    
    print(f"--- 생성된 더미 콘텐츠 ---")
    print(f"**주제:** {article_title}")
    print(f"**마크다운 결과물:**")
    print("```markdown")
    print(generated_markdown)
    print("```")
    print(f"파일 저장 위치: {output_filepath}")

    # Git operations to push to GitHub Pages
    repo_dir = os.path.dirname(__file__)
    
    # Initialize Git repository if not already and add remote
    if not os.path.exists(os.path.join(repo_dir, '.git')):
        run_git_command("git init", repo_dir)
        run_git_command(f"git remote add origin https://github.com/{config.GITHUB_USERNAME}/{config.GITHUB_REPO_NAME}.git", repo_dir)
    
    # Ensure we are on the 'main' branch
    run_git_command("git branch -M main", repo_dir)

    # Configure Git user and email (important for commits)
    run_git_command("git config user.name \"inhohwangg\" ", repo_dir)
    run_git_command("git config user.email \"hwanginho@users.noreply.github.com\" ", repo_dir) # Use GitHub noreply email for automation

    # Add the generated content and config/main script to staging
    run_git_command(f"git add {os.path.join('output', filename)}", repo_dir)
    run_git_command(f"git add {os.path.join('config.py')}", repo_dir) 
    run_git_command(f"git add {os.path.basename(__file__)}", repo_dir) # Add main.py itself
    run_git_command(f"git add .gitignore", repo_dir) # Add .gitignore itself

    # Commit the changes
    commit_message = f"refactor: Simplify content generation to dummy text for {target_keyword}"
    run_git_command(f"git commit -m \"{commit_message}\" ", repo_dir)

    # Fetch remote changes and rebase local changes on top, allowing unrelated histories for first sync
    run_git_command("git fetch origin", repo_dir)
    try:
        run_git_command("git pull --rebase origin main --allow-unrelated-histories", repo_dir)
    except Exception as e:
        print(f"Warning: git pull failed, attempting to push directly. Error: {e}")
        pass 

    # Push to GitHub
    run_git_command(f"git push -u origin {config.GITHUB_BRANCH}", repo_dir)
    print(f"콘텐츠가 GitHub 저장소 '{config.GITHUB_USERNAME}/{config.GITHUB_REPO_NAME}'의 '{config.GITHUB_BRANCH}' 브랜치에 성공적으로 푸시되었습니다.")
