//
//  ProfilePhotoView.swift
//  ACS Contacts
//
//  Created by snow on 09/23/24.
//

import Foundation
import SwiftUI

struct ProfilePhoto: View {
    var contact: Contact
    var size: CGFloat = 50
    
    var body: some View {
        AsyncImage(
            url: URL(string: contact.pictureUrl ?? ""),
            content: { image in
                image.resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(maxWidth: size, maxHeight: size)
            },
            placeholder: {
                ProgressView()
            }
        )
    }
}
