import SlideViewer 1.0
import Cpp 1.0

SlideDeck {
    Slide {
        SlideAttached.showPageNumber: false
        slideId: 0
        TextBase {
            font.pixelSize: 36
            anchors.horizontalCenter: parent.horizontalCenter
            text: "How to Write a Heap Profiler"
        }
        TextBase {
            font.pixelSize: 24
            anchors.horizontalCenter: parent.horizontalCenter

            text: "Dirty Details Beyond Standard C++"
        }

        Space { height: 75 }

        TextBase {
            font.pixelSize: 24
            anchors.horizontalCenter: parent.horizontalCenter

            text: "CppCon 2019"
        }

        TextBase {
            font.pixelSize: 24
            anchors.horizontalCenter: parent.horizontalCenter

            text: "presented by Milian Wolff"
        }

        Space { height: 20 }

        Image {
            anchors.horizontalCenter: parent.horizontalCenter

            source: "images/kdab.png"
        }
    }

    SlideSet {
        label: "part-talk"
        title: "How to Write a Heap Profiler"
        Introduction {}
        Preloading {}
        StackUnwinding {}
        SymbolResolution {}
        RuntimeAttaching {}
//         OutputDataFormat {}
    }

    Slide {
        slideId: 101
        title: "Road Towards A Real Heap Profiler"
        text: "* Efficient output data format
               ** Consider zstd compression
               ** Consider binary data format (e.g. protobuf or similar)
               ** Graphing essentially requires a good time series data format
               * API for custom allocators
               * Analysis GUI
               ** FlameGraph visualization is crucial
               * Handling other quirks
               ** forking, sub processes, clean shutdown, ..."
        Space { height: 25 }
        TextBase {
            text: "Please contribute to heaptrack instead of writing your own!"
            font.pixelSize: 30
        }
    }
    Slide {
        SlideAttached.showPageNumber: false
        slideId: 100

        TextBase {
            font.pixelSize: 50
            text: "Questions?"
            anchors.horizontalCenter: parent.horizontalCenter
        }

        Space { height: 25 }

        TextBase {
            anchors.horizontalCenter: parent.horizontalCenter
            font.pixelSize: 20
            text: "Milian Wolff
                <ul>
                    <li><a href=\"mailto:milian.wolff@kdab.com\">milian.wolff@kdab.com</a>
                    <li><a href=\"https://github.com/milianw/how-to-write-a-memory-profiler\">Example source code and slides</a></li>
                    <li>Heap Memory Profiler: <a href=\"https://github.com/KDE/heaptrack\">heaptrack</a></li>
                    <li>Linux Perf GUI: <a href=\"https://github.com/KDAB/hotspot\">hotspot</a></li>
                </ul>"
        }
        Space { height: 25 }

        Image {
            anchors.horizontalCenter: parent.horizontalCenter
            source: "images/kdab.png"
        }

    }
}

