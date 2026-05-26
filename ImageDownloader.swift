//
//  ImageDownloader.swift
//  LebenInDeutschland-DataParser
//
//  Created by Hassaan Ahmed on 25.05.26.
//

import Foundation

struct ImageDownloader {
    struct DownloadedImage {
        let sourceURL: URL
        let fileURL: URL
    }

    enum DownloadError: Error {
        case invalidURL(String)
        case invalidFileName(URL)
        case invalidResponse(URL)
    }

    let folderName: String
    let session: URLSession
    let fileManager: FileManager

    init(
        folderName: String = "QuestionImages",
        session: URLSession = .shared,
        fileManager: FileManager = .default
    ) {
        self.folderName = folderName
        self.session = session
        self.fileManager = fileManager
    }

    @discardableResult
    func downloadAllImages(from urlStrings: [String] = imageURLStrings) async throws -> [DownloadedImage] {
        let folderURL = try imagesFolderURL()
        try fileManager.createDirectory(at: folderURL, withIntermediateDirectories: true)

        return try await withThrowingTaskGroup(of: DownloadedImage.self) { group in
            for urlString in urlStrings {
                guard let url = URL(string: urlString) else {
                    throw DownloadError.invalidURL(urlString)
                }

                group.addTask {
                    try await downloadImage(from: url, to: folderURL)
                }
            }

            var downloadedImages: [DownloadedImage] = []
            for try await downloadedImage in group {
                downloadedImages.append(downloadedImage)
            }
            return downloadedImages.sorted { $0.fileURL.lastPathComponent < $1.fileURL.lastPathComponent }
        }
    }

    private func downloadImage(from url: URL, to folderURL: URL) async throws -> DownloadedImage {
        let fileName = url.lastPathComponent
        guard !fileName.isEmpty else {
            throw DownloadError.invalidFileName(url)
        }

        let destinationURL = folderURL.appendingPathComponent(fileName)
        let (temporaryURL, response) = try await session.download(from: url)

        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw DownloadError.invalidResponse(url)
        }

        if fileManager.fileExists(atPath: destinationURL.path) {
            try fileManager.removeItem(at: destinationURL)
        }
        try fileManager.moveItem(at: temporaryURL, to: destinationURL)

        return DownloadedImage(sourceURL: url, fileURL: destinationURL)
    }

    private func imagesFolderURL() throws -> URL {
        try fileManager.url(
            for: .documentDirectory,
            in: .userDomainMask,
            appropriateFor: nil,
            create: true
        )
        .appendingPathComponent(folderName, isDirectory: true)
    }
}

extension ImageDownloader {
    static let imageURLStrings: [String] = [
        "https://www.einbuergerungstest-online.de/img/fragen/021.png",
        "https://www.einbuergerungstest-online.de/img/fragen/055.png",
        "https://www.einbuergerungstest-online.de/img/fragen/070.png",
        "https://www.einbuergerungstest-online.de/img/fragen/130.png",
        "https://www.einbuergerungstest-online.de/img/fragen/176.png",
        "https://www.einbuergerungstest-online.de/img/fragen/181.png",
        "https://www.einbuergerungstest-online.de/img/fragen/187.png",
        "https://www.einbuergerungstest-online.de/img/fragen/209.png",
        "https://www.einbuergerungstest-online.de/img/fragen/216.png",
        "https://www.einbuergerungstest-online.de/img/fragen/226.png",
        "https://www.einbuergerungstest-online.de/img/fragen/235.png",
        "https://www.einbuergerungstest-online.de/img/fragen/331.png",
        "https://www.einbuergerungstest-online.de/img/fragen/338.png",
        "https://www.einbuergerungstest-online.de/img/fragen/321.png",
        "https://www.einbuergerungstest-online.de/img/fragen/328.png",
        "https://www.einbuergerungstest-online.de/img/fragen/301.png",
        "https://www.einbuergerungstest-online.de/img/fragen/308.png",
        "https://www.einbuergerungstest-online.de/img/fragen/311.png",
        "https://www.einbuergerungstest-online.de/img/fragen/318.png",
        "https://www.einbuergerungstest-online.de/img/fragen/341.png",
        "https://www.einbuergerungstest-online.de/img/fragen/348.png",
        "https://www.einbuergerungstest-online.de/img/fragen/361.png",
        "https://www.einbuergerungstest-online.de/img/fragen/368.png",
        "https://www.einbuergerungstest-online.de/img/fragen/351.png",
        "https://www.einbuergerungstest-online.de/img/fragen/358.png",
        "https://www.einbuergerungstest-online.de/img/fragen/371.png",
        "https://www.einbuergerungstest-online.de/img/fragen/378.png",
        "https://www.einbuergerungstest-online.de/img/fragen/381.png",
        "https://www.einbuergerungstest-online.de/img/fragen/388.png",
        "https://www.einbuergerungstest-online.de/img/fragen/391.png",
        "https://www.einbuergerungstest-online.de/img/fragen/398.png",
        "https://www.einbuergerungstest-online.de/img/fragen/401.png",
        "https://www.einbuergerungstest-online.de/img/fragen/408.png",
        "https://www.einbuergerungstest-online.de/img/fragen/441.png",
        "https://www.einbuergerungstest-online.de/img/fragen/448.png",
        "https://www.einbuergerungstest-online.de/img/fragen/411.png",
        "https://www.einbuergerungstest-online.de/img/fragen/418.png",
        "https://www.einbuergerungstest-online.de/img/fragen/421.png",
        "https://www.einbuergerungstest-online.de/img/fragen/428.png",
        "https://www.einbuergerungstest-online.de/img/fragen/431.png",
        "https://www.einbuergerungstest-online.de/img/fragen/438.png",
        "https://www.einbuergerungstest-online.de/img/fragen/451.png",
        "https://www.einbuergerungstest-online.de/img/fragen/458.png"
    ]
}
