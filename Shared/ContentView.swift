//
//  ContentView.swift
//  Shared
//
//  Created by Harry Shamansky on 12/27/20.
//  Copyright © 2020 Harry Shamansky. All rights reserved.
//

import AVFoundation
import PhotosUI
import SwiftUI

struct ContentView: View {
    
    @StateObject var streamSource = StreamSource()
    @StateObject var metadataStore = MetadataStore()
    @State var presentingPhotoPicker: Bool = false
    
    let multipeerManager = MultipeerManager.shared
    
    var body: some View {
        VStack(alignment: .center) {
            if metadataStore.canEdit {
                ZStack(alignment: Alignment(horizontal: .center, vertical: .bottom)) {
                    metadataStore.albumImage
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(height: albumArtSize)
                        .cornerRadius(12.0)
                        .padding()
                    #if !os(tvOS)
                    Button("Upload") {
                        presentingPhotoPicker = true
                    }.offset(x: 0.0, y: -40.0)
                    #endif
                }
                #if !os(tvOS)
                HStack {
                    VStack {
                        TextField("Album Title", text: $metadataStore.albumTitle)
                            .multilineTextAlignment(.center)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .padding([.leading, .trailing], 40)
                        TextField("Artist", text: $metadataStore.artist)
                            .multilineTextAlignment(.center)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .padding([.leading, .trailing], 40)
                    }
                }
                #elseif os(tvOS)
                TextField("Album Title", text: $metadataStore.albumTitle)
                    .multilineTextAlignment(.center)
                    .frame(width: albumArtSize)
                TextField("Artist", text: $metadataStore.artist)
                    .multilineTextAlignment(.center)
                    .frame(width: albumArtSize)
                #endif
            } else {
                metadataStore.albumImage
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(height: albumArtSize)
                    .cornerRadius(12.0)
                    .padding()
                #if os(tvOS)
                VStack {
                    Text(metadataStore.albumTitle).font(.headline)
                    Text(metadataStore.artist).font(.subheadline)
                }
                #elseif os(iOS)
                HStack {
                    VStack {
                        Text(metadataStore.albumTitle).font(.headline)
                        Text(metadataStore.artist).font(.subheadline)
                        Button {
                            self.metadataStore.canEdit = true
                        } label: {
                            Image(systemName: "pencil")
                        }
                    }
                }.offset(x: 30.0)
                #endif
            }
            HStack {
                #if os(iOS)
                playStopButton
                    .font(.title)
                    .frame(width: 50, height: 50)
                AirPlayRoutePickerView()
                    .frame(width: 50, height: 50)
                #elseif os(tvOS)
                playStopButton
                AirPlayRoutePickerView()
                    .frame(width: 50, height: 50)
                #endif
            }.padding(.top, 40)
        }.tabItem {
            Image(systemName: "play")
            Text("Now Playing")
        }.sheet(isPresented: $presentingPhotoPicker) {
            #if !os(tvOS)
            let configuration = PHPickerConfiguration(photoLibrary: PHPhotoLibrary.shared())
            PhotoPicker(configuration: configuration,
                        isPresented: $presentingPhotoPicker,
                        albumImage: $metadataStore.albumImage,
                        albumImageData: $metadataStore.albumImageData)
            #endif
        }.onAppear {
            #if os(tvOS)
            UIApplication.shared.isIdleTimerDisabled = true
            #endif
            metadataStore.multipeerManager = multipeerManager
            multipeerManager.metadataStore = metadataStore
            multipeerManager.streamSource = streamSource
            streamSource.multipeerManager = multipeerManager
        }
    }
    
    var albumArtCornerRadius: CGFloat {
        #if os(tvOS)
        return 12.0
        #else
        return 6.0
        #endif
    }
    
    var albumArtSize: CGFloat {
        #if os(tvOS)
        return 600.0
        #else
        return 200.0
        #endif
    }
    
    var playStopButton: some View {
        Button(action: {
            streamSource.playing.toggle()
        }) {
            if streamSource.playing {
                #if os(tvOS)
                Image(systemName: "stop.fill")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(height: 30)
                    .padding(EdgeInsets(top: 9, leading: 0, bottom: 8, trailing: 0))
                #else
                Image(systemName: "stop.fill")
                #endif
            } else {
                #if os(tvOS)
                Image(systemName: "play.fill")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(height: 30)
                    .padding(EdgeInsets(top: 9, leading: 0, bottom: 8, trailing: 0))
                #else
                Image(systemName: "play.fill")
                #endif
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}