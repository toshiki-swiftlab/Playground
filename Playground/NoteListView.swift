import SwiftUI
import CoreData

struct NoteListView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(sortDescriptors: []) private var notes: FetchedResults<Note>
    
    @State private var tfAlertType = 0
    @State private var editingNote: Note? = nil
    @State private var isTFAlertPresented = false
    @State private var alertTFText = ""
    @State private var searchText = ""
    
    var body: some View {
        NavigationStack {
            TextField("検索", text: $searchText)
                .textFieldStyle(.roundedBorder)
                .padding(.horizontal)
            List {
                ForEach(filteredNotes, id: \.objectID) { note in
                    Text(note.content ?? "")
                        .swipeActions(edge: .trailing) {
                            Button("編集") {
                                tfAlertType = 1
                                editingNote = note
                                alertTFText = note.content ?? ""
                                isTFAlertPresented = true
                            }
                            .tint(.blue)
                            Button("削除", role: .destructive) {
                                viewContext.delete(note)
                                do {
                                    try viewContext.save()
                                } catch {
                                    print("削除に失敗しました: \(error)")
                                }
                            }
                        }
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
            .alert(
                tfAlertType == 0 ? "新規作成" : "編集",
                isPresented: $isTFAlertPresented,
                actions: {
                    TextField("ブロッコリーを買う🥦", text: $alertTFText)
                    Button("作成", action: {
                        if tfAlertType == 0 {
                            onCreateNoteButton(nil)
                        } else if tfAlertType == 1 {
                            onCreateNoteButton(editingNote)
                        }
                    })
                    Button("キャンセル", action: onCalcelButton)
                }, message: {
                    Text("メモを入力してください！📝")
                }
            )
        }
    }
    
    var filteredNotes: [Note] {
        if searchText.isEmpty {
            return Array(notes)
        } else {
            return notes.filter { note in
                (note.content ?? "").localizedCaseInsensitiveContains(searchText)
            }
        }
    }
}

extension NoteListView {
    
    private func onCalcelButton() {
        alertTFText = ""
        isTFAlertPresented = false
    }
    
    private func onCreateNoteButton(_ note: Note?) {
        if tfAlertType == 0 {
            let newNote = Note(context: viewContext)
            newNote.content = alertTFText
            do {
                try viewContext.save()
            } catch {
                print("Error saving managed object context: \(error)")
            }
        } else if tfAlertType == 1 {
            note?.content = alertTFText
            do {
                try viewContext.save()
            } catch {
                print("Error saving managed object context: \(error)")
            }
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
