"""
Test file_utils module

"""
from utils import file_utils


def test_get_valid_path():

    root_path = "."
    paths = file_utils.get_valid_path(root_path)
    assert "./201709/3.hangawui/hangawui_result.PNG" in paths


def test_is_ignored_path():

    ignored_path = "./.git/asjdfk"
    assert file_utils.is_ignored(ignored_path, file_utils.IGNORED_PATH) == True

    not_ignored_path = "./201709/3.hangawui/result.R"
    assert file_utils.is_ignored(not_ignored_path, file_utils.IGNORED_PATH) == False


def test_extract_information():

    path_to_extract = "./201709/3.hangawui/hangawui_result.PNG"
    node = file_utils.create_node(path_to_extract)

    assert node.year == 2017
    assert node.month == 9
    assert node.subject == "3.hangawui"
    assert node.path == path_to_extract
