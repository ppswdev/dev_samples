//
//  GoogleDriveManageViewController.swift
//  MyCloudDrive
//
//  Created by xiaopin on 2024/9/25.
//

import UIKit
import GoogleAPIClientForREST

class GoogleDriveManageViewController: UIViewController {
    
    /// 记录文件夹的项
    var folderCounts = [String:Int]()
    
    var dataArray = [GTLRDrive_File]()
    var selectedFiles = Set<GTLRDrive_File>()
    var stacks = [(id:"root",name:"MyDrive")]
    var tableView: UITableView!
    var breadcrumbStackView: UIStackView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        view.backgroundColor = .white
        setupNavigationBar()
        setupBreadcrumbStackView()
        setupTableView()
        loadFiles()
    }

    func setupNavigationBar() {
        self.navigationItem.title = "Google Drive"
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Select All", style: .plain, target: self, action: #selector(selectAllFiles))
    }

    func setupBreadcrumbStackView() {
        breadcrumbStackView = UIStackView()
        breadcrumbStackView.backgroundColor = .clear
        breadcrumbStackView.axis = .horizontal
        breadcrumbStackView.alignment = .leading
        breadcrumbStackView.spacing = 2
        breadcrumbStackView.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(breadcrumbStackView)
        
        NSLayoutConstraint.activate([
            breadcrumbStackView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor, constant: 10),
            breadcrumbStackView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 15),
            breadcrumbStackView.trailingAnchor.constraint(lessThanOrEqualTo: self.view.trailingAnchor, constant: -15),
            breadcrumbStackView.heightAnchor.constraint(equalToConstant: 30)
        ])
    }
    
    func setupTableView() {
        tableView = UITableView(frame: .zero, style: .plain)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(CustomFileCell.self, forCellReuseIdentifier: "CustomFileCell")
        tableView.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(tableView)
        
        // Add download button
        let downloadButton = UIButton(type: .system)
        downloadButton.backgroundColor = .orange
        downloadButton.setTitle("Download Selected Files", for: .normal)
        downloadButton.setTitleColor(.white, for: .normal)
        downloadButton.addTarget(self, action: #selector(downloadSelectedFiles), for: .touchUpInside)
        downloadButton.translatesAutoresizingMaskIntoConstraints = false
        downloadButton.layer.cornerRadius = 25
        self.view.addSubview(downloadButton)

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: breadcrumbStackView.bottomAnchor, constant: 10),
            tableView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: downloadButton.topAnchor, constant: -10),
            
            downloadButton.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 10),
            downloadButton.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -10),
            downloadButton.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor, constant: -10),
            downloadButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }

    func updateBreadcrumb() {
        breadcrumbStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        for (index, file) in stacks.enumerated() {
            let label = ClickableLabel()
            label.text = file.name
            label.textColor = index == stacks.count - 1 ? .gray : .blue
            label.onClick = { [weak self] in
                guard let self = self else{return}
                self.goFolder(index: index)
            }
            breadcrumbStackView.addArrangedSubview(label)
            
            if index < stacks.count - 1 {
                let separator = UILabel()
                separator.text = ">"
                separator.textColor = .gray
                breadcrumbStackView.addArrangedSubview(separator)
            }
        }
    }
    
    func loadFiles() {
        guard let id = stacks.last?.id else{return}
        print("current load : \(stacks.last!)")
        
        let query = GTLRDriveQuery_FilesList.query()
        query.pageSize = 100
        query.fields = "nextPageToken, files(id, name, mimeType, size, modifiedTime)"
        query.q = "'\(id)' in parents"
        
        CloudDriveManager.shared.driveService.executeQuery(query) { (ticket, result, error) in
            if let error = error {
                print("Failed to list files: \(error)")
                return
            }
            
            guard let files = (result as? GTLRDrive_FileList)?.files else {
                print("No files found.")
                return
            }
            
            self.dataArray = files
            DispatchQueue.main.async {
                self.tableView.reloadData()
                self.updateBreadcrumb()
            }
            
            // 获取每个子目录的文件和目录总数
            for file in files {
                if file.mimeType == "application/vnd.google-apps.folder" {
                    self.getFolderDetails(id: file.identifier!, folderPath: file.name!)
                }
            }
        }
    }

    func getFolderDetails(id: String, folderPath: String) {
        let query = GTLRDriveQuery_FilesList.query()
        query.q = "'\(id)' in parents"
        
        CloudDriveManager.shared.driveService.executeQuery(query) { (ticket, result, error) in
            if let error = error {
                print("Failed to list folder: \(error)")
                return
            }
            
            guard let files = (result as? GTLRDrive_FileList)?.files else {
                print("No files found.")
                return
            }
            
            var fileCount = 0
            var folderCount = 0

            for file in files {
                if file.mimeType == "application/vnd.google-apps.folder" {
                    folderCount += 1
                } else {
                    fileCount += 1
                }
            }
            self.folderCounts[id] = folderCount + fileCount
            print("Folder path: \(folderPath)")
            print("Total files: \(fileCount)")
            print("Total folders: \(folderCount)")
            print("folderCounts: \(id) : \(self.folderCounts[id] ?? 0)")
            
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    
    func downloadFile(file: GTLRDrive_File, to destinationURL: URL) {
        let query = GTLRDriveQuery_FilesGet.queryForMedia(withFileId: file.identifier!)
        
        CloudDriveManager.shared.driveService.executeQuery(query) { (ticket, fileData, error) in
            if let error = error {
                print("Failed to download file: \(error)")
                return
            }
            
            guard let dataObject = fileData as? GTLRDataObject else {
                print("No data found.")
                return
            }
            
            let data = dataObject.data
            
            do {
                try data.write(to: destinationURL)
                print("Downloaded file to: \(destinationURL)")
            } catch {
                print("Failed to write file: \(error)")
            }
        }
    }

    func downloadFolder(folder: GTLRDrive_File, to destinationURL: URL) {
        let folderPath = folder.name!
        let destinationFolderURL = destinationURL.appendingPathComponent(folderPath)
        
        do {
            try FileManager.default.createDirectory(at: destinationFolderURL, withIntermediateDirectories: true, attributes: nil)
        } catch {
            print("Failed to create directory: \(error)")
            return
        }
        
        let query = GTLRDriveQuery_FilesList.query()
        query.q = "'\(folder.identifier!)' in parents"
        
        CloudDriveManager.shared.driveService.executeQuery(query) { (ticket, result, error) in
            if let error = error {
                print("Failed to list folder: \(error)")
                return
            }
            
            guard let files = (result as? GTLRDrive_FileList)?.files else {
                print("No files found.")
                return
            }
            
            for file in files {
                if file.mimeType == "application/vnd.google-apps.folder" {
                    self.downloadFolder(folder: file, to: destinationFolderURL)
                } else {
                    let fileDestinationURL = destinationFolderURL.appendingPathComponent(file.name!)
                    self.downloadFile(file: file, to: fileDestinationURL)
                }
            }
        }
    }
}

extension GoogleDriveManageViewController{
    @objc func goBack() {
        if stacks.count > 1 {
            stacks.removeLast()
        }
        loadFiles()
        if stacks.count == 1 {
            self.navigationItem.leftBarButtonItem = nil
        }
    }
    
    func goFolder(index:Int){
        if index >= 0 && index < stacks.count {
            stacks.removeSubrange((index + 1)..<stacks.count)
            loadFiles()
        }
    }
    
    func goNextFolder(id:String, name:String){
        stacks.append((id: id, name: name))
        loadFiles()
    }
    
    @objc func downloadSelectedFiles() {
        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        
        for file in selectedFiles {
            if file.mimeType == "application/vnd.google-apps.folder" {
                downloadFolder(folder: file, to: documentsURL)
            } else {
                let fileDestinationURL = documentsURL.appendingPathComponent(file.name!)
                downloadFile(file: file, to: fileDestinationURL)
            }
        }
    }

    @objc func selectAllFiles() {
        if selectedFiles.count == dataArray.count {
            selectedFiles.removeAll()
        } else {
            selectedFiles = Set(dataArray)
        }
        tableView.reloadData()
    }
}

extension GoogleDriveManageViewController: UITableViewDelegate, UITableViewDataSource {
    // MARK: - UITableViewDataSource
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CustomFileCell", for: indexPath) as! CustomFileCell
        let file = dataArray[indexPath.row]
        
        // 设置图标，标题和小标题
        cell.titleLabel.text = file.name
        if file.mimeType == "application/vnd.google-apps.folder" {
            cell.iconImageView.image = UIImage(named: "folder_icon")
            cell.subtitleLabel.text = "\(folderCounts[file.identifier!] ?? 0)项"
        } else {
            cell.iconImageView.image = UIImage(named: "file_icon")
            let fileSize = ByteCountFormatter.string(fromByteCount: Int64(file.size?.int64Value ?? 0), countStyle: .file)
            let dateFormatter = DateFormatter()
            dateFormatter.dateStyle = .short
            dateFormatter.timeStyle = .short
            let modifiedDate = dateFormatter.string(from: file.modifiedTime?.date ?? Date())
            cell.subtitleLabel.text = "\(fileSize) | \(modifiedDate)"
        }
        
        // 设置选中按钮
        let imageName = selectedFiles.contains(file) ? "checkbox_1" : "checkbox_0"
        cell.checkboxImageView.setImage(UIImage(named: imageName), for: .normal)
        cell.checkClosure = { [weak self] in
            guard let self = self else { return }
            if self.selectedFiles.contains(file) {
                self.selectedFiles.remove(file)
            } else {
                self.selectedFiles.insert(file)
            }
            tableView.reloadRows(at: [indexPath], with: .automatic)
        }
        return cell
    }
    
    // MARK: - UITableViewDelegate
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let file = dataArray[indexPath.row]
        if file.mimeType == "application/vnd.google-apps.folder" {
            goNextFolder(id: file.identifier!, name: file.name!)
        } else {
            if selectedFiles.contains(file) {
                selectedFiles.remove(file)
            } else {
                selectedFiles.insert(file)
            }
            tableView.reloadRows(at: [indexPath], with: .automatic)
        }
    }
}
