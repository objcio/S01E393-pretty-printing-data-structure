import SwiftUI

indirect enum Doc {
    case empty
    case text(String)
    case sequence(Doc, Doc)
    case newline
    case indent(Doc)
    case choice(Doc, Doc) // left is widest doc
}

struct PrettyState {
    var columnWidth: Int
    var stack: [(indentation: Int, Doc)]
    var tabWidth = 4

    init(columnwidth: Int, doc: Doc) {
        self.columnWidth = columnwidth
        self.stack = [(0, doc)]
    }

    mutating func render() -> String {
        guard let (indentation, el) = stack.popLast() else { return "" }
        switch el {
        case .empty:
            return "" + render()
        case .text(let string):
            return string + render()
        case .sequence(let doc, let doc2):
            stack.append((indentation, doc2))
            stack.append((indentation, doc))
            return render()
        case .newline:
            return "\n" + String(repeating: " ", count: indentation * tabWidth) + render()
        case .indent(let doc):
            stack.append((indentation + 1, doc))
            return render()
        case .choice(let doc, let doc2):
            fatalError()
        }
    }

}


extension Doc {
    func pretty(columns: Int) -> String {
        var state = PrettyState(columnwidth: columns, doc: self)
        return state.render()
    }

    static func +(lhs: Doc, rhs: Doc) -> Doc {
        .sequence(lhs, rhs)
    }
}

let doc = Doc.indent(Doc.text("func hello() {") + .indent(.newline + .text("print(\"Hello\")")) + .newline + .text("}"))

struct ContentView: View {
    @State var width = 20.0
    var body: some View {
        VStack {
            VStack(alignment: .leading) {
                Text(String(repeating: ".", count: Int(width)))
                Text(doc.pretty(columns: Int(width)))
                    .fixedSize()
            }
            Spacer()
            Slider(value: $width, in: 0...80)
        }
        .monospaced()
        .padding()
    }
}

#Preview {
    ContentView()
}
