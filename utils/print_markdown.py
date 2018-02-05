"""
Create README.md file

Usage:
    python print_markdown.py

"""
import subprocess
from itertools import groupby

from file_utils import Quiz, create_node, create_quizs, get_valid_path

PATH_LIST = sorted(get_valid_path("."))
NODE_LIST = [create_node(p) for p in PATH_LIST]
QUIZ_LIST = sorted(
    create_quizs(NODE_LIST), key=lambda q: (q.year, q.month, q.subject))

MARKDOWN_HEADER = """
<div align="center">
<img src="./assets/logo.png" alt="Logo" width="50%">
</div>

# R Korea Weekly Quiz

R Korea에서 진행한 주말맞이 R Quiz 모음입니다.
"""

MARKDOWN_FOOTER = """
## NOTES
이 파일은 자동으로 생성되었습니다."""


def print_year(year: int) -> str:
    """Returns `year` in markdown format"""
    return f"## {year} 년"


def print_month(month: int) -> str:
    """Returns `month` in markdown format"""
    return f"### {month} 월"


def print_image(quiz: Quiz) -> str:
    """Returns <img tag>"""
    if not quiz.image_path:
        return ""

    template = f"""
<div align="center">
  <img src="{quiz.image_path}" alt="Quiz Image" width="50%" max-height="30%">
</div>
"""
    return template


def print_question(quiz: Quiz) -> str:
    """Returns a link to the question in markdown format"""
    template = f"[{quiz.subject}]({quiz.quiz_path})"
    return template


def print_answer(quiz: Quiz) -> str:
    """Returns a link to the question answer"""
    if not quiz.answer_path:
        return ""

    template = f"""<a href="{quiz.answer_path}" target="_blank">정답 보기</a>"""
    return template


def print_quiz(quiz: Quiz) -> str:
    """Returns a quiz in markdown format"""
    subject = quiz.subject

    link = f"""
<a href="{quiz.quiz_path}" target="_blank">문제 바로 가기</a>
"""

    with open(quiz.quiz_path, "r") as f:
        question = f.readline().strip()

    image_tag = print_image(quiz)
    answer_tag = print_answer(quiz)

    template = f"""<details><summary>{subject}</summary>
    {link}
<div>{question}</div>
    {image_tag}
{answer_tag}
</details>
"""

    return template


def get_markdown() -> str:
    """Returns a complete markdown"""
    md_buffer = ""

    for year, y_group in groupby(QUIZ_LIST, key=lambda q: q.year):

        md_buffer += print_year(year) + "\n"
        for month, group in groupby(y_group, key=lambda q: q.month):

            md_buffer += print_month(month) + "\n"

            for node in group:
                md_buffer += print_quiz(node) + "\n"

    return md_buffer


def clean_toc(toc: str) -> str:
    """Each line in `toc` has 6 unnecessary spaces, so get rid of them"""
    lines = toc.splitlines()
    return "\n".join(line[6:] for line in lines)


def main():
    """Main Function"""
    buffer = get_markdown()
    result = subprocess.run(
        ["./utils/gh-md-toc", "-", "$0"],
        stdout=subprocess.PIPE,
        input=buffer.encode("utf-8"))

    toc = result.stdout.decode('utf-8')
    toc = clean_toc(toc)

    markdown = f"""{MARKDOWN_HEADER}

Table of Contents
=======================

{toc}

{buffer}

{MARKDOWN_FOOTER}
"""

    with open("README.md", "w") as f:
        f.write(markdown)


if __name__ == '__main__':
    main()
