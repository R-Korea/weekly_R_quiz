"""
List files in order


Create Markdown File

## Year
### Month
#### Subject

<img src="image" alt="image">


"""
import os
from typing import List, Dict, DefaultDict
from collections import namedtuple, defaultdict

IGNORED_PATH = [
    "assets", ".git", ".cache", "Dockerfile", "docker-compose.yml", "utils",
    "tests", "temp", ".mypy_cache", "main.py", "README.md", "LICENSE"
]


def is_ignored(path: str, ignored_list: List[str]) -> bool:
    """Return if path should be ignored

    Args:
        path (str): Path to test
        ignored_list (List[str]): Path should not contain any of the list

    Returns:
        bool: If the path should be ignored, it returns True else False

    """
    for ignored_path in ignored_list:
        if ignored_path in path:
            return True
    return False


def get_valid_path(root_path: str) -> List[str]:
    """Returns a list of valid file paths

    Args:
        root_path (str): The top starting path such as "."

    Returns:
        List[str]: List of valid path
    """
    paths = []
    for dirpath, _, filenames in os.walk(root_path):

        for name in filenames:
            _path = os.path.join(dirpath, name)

            if not is_ignored(_path, IGNORED_PATH):
                paths.append(_path)

    return paths


Node = namedtuple("Node", ["year", "month", "subject", "path"])
Quiz = namedtuple("Quiz", [
    "year", "month", "subject", "answer_path", "quiz_path", "image_path"
])


def create_node(path: str) -> Node:
    """Extract information from path and create `Node`

    Args:
        path (str): Path to a file

    Returns:
        Node: Node information
    """
    _, date, subject, _ = path.split(os.sep)

    year = int(date[:4])
    month = int(date[-2:])

    return Node(year, month, subject, path)


def create_quizzes(nodes: List[Node]) -> List[Quiz]:
    quiz_list = defaultdict(dict)  # type: DefaultDict[str, Dict[str, str]]

    for node in nodes:
        key = "{}!{}!{}".format(node.year, node.month, node.subject)
        if node.path.lower().endswith("png"):
            quiz_list[key]["image_path"] = node.path
        elif "quiz" in node.path.lower():
            quiz_list[key]["quiz_path"] = node.path
        elif "answer" in node.path.lower():
            quiz_list[key]["answer_path"] = node.path

    result = []
    for key, quiz in quiz_list.items():
        year, month, subject = key.split("!")

        quiz_node = Quiz(
            int(year),
            int(month), ". ".join(subject.split(".")),
            quiz.get("answer_path", None),
            quiz.get("quiz_path", None),
            quiz.get("image_path", None))
        result.append(quiz_node)

    return result
