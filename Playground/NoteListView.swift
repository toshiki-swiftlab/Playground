import SwiftUI
import CoreData

struct NoteListView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(sortDescriptors: []) private var notes: FetchedResults<Note>
    
    @State private var isTFAlertPresented = false
    @State private var alertTFText = ""
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(notes, id: \.objectID) { note in
                    Text(note.content ?? "")
                }
                .onDelete(perform: deleteNote)
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("新規作成") {
                        isTFAlertPresented = true
                    }
                }
            }
            .alert("新規作成", isPresented: $isTFAlertPresented, actions: {
                TextField("ブロッコリーを買う🥦", text: $alertTFText)
                Button("作成", action: onCreateNoteButton)
                Button("キャンセル", action: onCalcelButton)
            }, message: {
                Text("メモを入力してください！📝")
            })
        }
    }
}

extension NoteListView {
    
    private func onCalcelButton() {
        alertTFText = ""
        isTFAlertPresented = false
    }
    
    private func onCreateNoteButton() {
        let newNote = Note(context: viewContext)
        newNote.content = alertTFText
        do {
            try viewContext.save()
        } catch {
            print("Error saving managed object context: \(error)")
        }
    }
    
    func deleteNote(at offsets: IndexSet) {
        for index in offsets {
            let note = notes[index]
            // ここで CoreData から削除
            viewContext.delete(note)
        }

        do {
            try viewContext.save()
        } catch {
            // エラー処理
            print("削除に失敗しました: \(error)")
        }
    }
}

#Preview {
    NoteListView()
}
