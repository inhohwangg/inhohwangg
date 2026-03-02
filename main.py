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
    # Simplified content generation for demonstration
    if "스마트폰" in topic:
        title = f"혁신적인 {topic} 상세 리뷰 및 구매 가이드"
        intro = f"오늘날의 스마트폰 시장은 끊임없이 진화하고 있으며, 최근 출시된 {topic}은 사용자들에게 전에 없던 경험을 선사합니다. 이 리뷰에서는 {topic}의 주요 특징과 성능을 심층적으로 분석하고, 현명한 구매를 위한 가이드를 제공합니다."
        feature1 = "압도적인 카메라 성능: 야간 촬영도 선명하게!"
        feature2 = "초고속 프로세서: 어떤 앱도 버벅임 없이 쾌적하게!"
        feature3 = "하루 종일 가는 배터리: 충전 걱정 없이 사용하세요!"
        benefits = f"{topic}은 단순한 스마트폰을 넘어, 당신의 일상에 혁신을 가져다줄 강력한 도구입니다. 최고의 성능과 사용자 경험을 원한다면, {topic}은 후회 없는 선택이 될 것입니다."
        conclusion = f"지금 바로 {topic}의 놀라운 기능을 경험해보세요. 이 스마트폰은 당신의 디지털 라이프를 한 단계 업그레이드할 것입니다."
        
        # Generic Coupang search link with affiliate ID
        product_search_query = topic.replace(" ", "+")
        affiliate_link = f"https://www.coupang.com/np/search?q={product_search_query}&channel=user_input&listSize=30&isInitialSearch=Y&source=search&memberID={affiliate_id}"

    else:
        # Generic fallback content
        title = f"새로운 제품: {topic}의 모든 것"
        intro = f"이 글에서는 {topic}에 대해 자세히 알아보겠습니다."
        feature1 = "특징 1"
        feature2 = "특징 2"
        feature3 = "특징 3"
        benefits = "이 제품의 장점은 매우 많습니다."
        conclusion = "지금 바로 경험해보세요."
        affiliate_link = f"https://www.coupang.com/?memberID={affiliate_id}" # Fallback generic link


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

    # For the first content, use the first keyword
    first_keyword = config.KEYWORDS[0]
    
    article_title, generated_markdown = generate_article(first_keyword, affiliate_id)

    output_dir = os.path.join(os.path.dirname(__file__), 'output')
    os.makedirs(output_dir, exist_ok=True)
    
    # Sanitize title for filename
    filename = f"{article_title.replace(' ', '_').replace('/', '_')}.md"
    output_filepath = os.path.join(output_dir, filename)

    with open(output_filepath, 'w', encoding='utf-8') as f:
        f.write(generated_markdown)
    
    print(f"--- 첫 번째 자동 생성 콘텐츠 ---")
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
    commit_message = f"fix: Use .env for affiliate ID and add .gitignore"
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
