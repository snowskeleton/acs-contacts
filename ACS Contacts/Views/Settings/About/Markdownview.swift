//
//  MarkdownView.swift
//  OSTRich
//
//  Created by snow on 9/2/24.
//

import SwiftUI
import MarkdownUI

struct MarkdownView: View {
    var markdownText: String
    var title: String
    
    init(markdownFile: String, title: String?) {
        self.title = title ?? ""
        let fileParts = markdownFile.split(separator: ".").map(String.init)
        let fileName: String
        var fileExtension: String = ""
        
        fileName = fileParts.first ?? markdownFile
        if fileParts.count > 1 {
            fileExtension = fileParts.last ?? "md"
        }
        
        guard let url = Bundle.main.url(forResource: fileName, withExtension: fileExtension) else {
            self.markdownText = "File not found"
            return
        }
        
        do {
            self.markdownText = try String(contentsOf: url, encoding: .utf8)
        } catch {
            self.markdownText = "Error loading file"
        }
    }

    var body: some View {
        ScrollView {
            VStack {
                Markdown(markdownText)
                    .padding(10)
            }
            .navigationTitle(title)
        }
    }
}
