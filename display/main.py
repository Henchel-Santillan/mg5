import sys

from PySide6.QtGui import QGuiApplication
from PySide6.QtQml import QQmlApplicationEngine

def main():
    app = QGuiApplication(sys.argv)
    qml_engine = QQmlApplicationEngine()

    qml_engine.addImportPath(sys.path[0])
    qml_engine.loadFromModule("di", "main")

    if not qml_engine.rootObjects():
        print("App launch failed: no root objects found.")
        sys.exit(-1)

    exit_code = app.exec()
    del engine
    sys.exit(exit_code)

if __name__ == "__main__":
    main()
