//
//  DropboxManageViewController.swift
//  MyCloudDrive
//
//  Created by xiaopin on 2024/9/21.
//

import UIKit
import SwiftyDropbox

extension Files.Metadata: Hashable {
    public static func == (lhs: Files.Metadata, rhs: Files.Metadata) -> Bool {
        return lhs.name == rhs.name && lhs.pathLower == rhs.pathLower
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(name)
        hasher.combine(pathLower)
    }
}

class FileModel:Codable{
    var id:String?
    var is_file:Bool = false
    var title:String?
    var remote_path:String?
    var size:UInt64 = 0
    var modified:Date?
    var isdownloadable:Bool = true
    var file_hash:String?
    
    var files = [FileModel]()
}

class ClickableLabel: UILabel {
    var onClick: (() -> Void)?

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }

    private func setup() {
        isUserInteractionEnabled = true
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(labelTapped))
        addGestureRecognizer(tapGesture)
    }

    @objc private func labelTapped() {
        onClick?()
    }
}

class DropboxManageViewController: UIViewController {
    
    /// 记录文件夹的项
    var folderCounts = [String:Int]()
    
    var dataArray = [Files.Metadata]()
    var selectedFiles = Set<Files.Metadata>()
    var tableView: UITableView!
    var currentPath: String = ""
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
        self.navigationItem.title = "Dropbox"
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
        
        var paths = currentPath.split(separator: "/").map(String.init)
        paths.insert("MyDrive", at: 0)
        print("paths \(paths) currentPath： \(currentPath)")
        for (index, path) in paths.enumerated() {
            let label = ClickableLabel()
            label.text = path
            label.textColor = index == paths.count - 1 ? .gray : .blue
            label.onClick = { [weak self] in
                if index == 0 {
                    self?.loadFiles(path: "")
                    return
                }
                var newPaths = paths.prefix(index+1)
                newPaths.remove(at: 0)
                let path = "/\(newPaths.joined(separator: "/"))"
                self?.loadFiles(path: path)
            }
            breadcrumbStackView.addArrangedSubview(label)
            
            if index < paths.count - 1 {
                let separator = UILabel()
                separator.text = ">"
                separator.textColor = .gray
                breadcrumbStackView.addArrangedSubview(separator)
            }
        }
    }
    
    func loadFiles(path: String = "") {
        print("load path : \(path)")
        guard let client = DropboxClientsManager.authorizedClient else { return }
        
        client.files.listFolder(path: path).response { result, error in
            if let result = result {
                print("Files: \(result.entries)")
                self.dataArray = result.entries
                self.currentPath = path
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                    self.updateBreadcrumb()
                }
                
                // 获取每个子目录的文件和目录总数
                for entry in result.entries {
                    if let folderMetadata = entry as? Files.FolderMetadata {
                        self.getFolderDetails(id: folderMetadata.id, folderPath: folderMetadata.pathLower ?? "")
                    }
                }
            } else if let error = error {
                print("Failed to list files: \(error)")
            }
        }
    }

    func getFolderDetails(id:String, folderPath: String) {
        guard let client = DropboxClientsManager.authorizedClient else { return }
        
        client.files.listFolder(path: folderPath).response { [weak self] result, error in
            if let self = self, let result = result {
                var fileCount = 0
                var folderCount = 0

                for entry in result.entries {
                    if entry is Files.FileMetadata {
                        fileCount += 1
                    } else if entry is Files.FolderMetadata {
                        folderCount += 1
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
            } else if let error = error {
                print("Failed to list folder: \(error)")
            }
        }
    }
    
    func downloadFile(fileMetadata: Files.FileMetadata, to destinationURL: URL) {
        guard let client = DropboxClientsManager.authorizedClient else { return }
        
        client.files.download(path: fileMetadata.pathLower ?? "", destination: destinationURL).response { response, error in
            if let response = response {
                print("Downloaded file to: \(response.1)")
            } else if let error = error {
                print("Failed to download file: \(error)")
            }
        }
    }

    func downloadFolder(folderMetadata: Files.FolderMetadata, to destinationURL: URL) {
        guard let client = DropboxClientsManager.authorizedClient else { return }
        
        let folderPath = folderMetadata.pathLower ?? ""
        let destinationFolderURL = destinationURL.appendingPathComponent(folderMetadata.name)
        
        do {
            try FileManager.default.createDirectory(at: destinationFolderURL, withIntermediateDirectories: true, attributes: nil)
        } catch {
            print("Failed to create directory: \(error)")
            return
        }
        
        client.files.listFolder(path: folderPath).response { result, error in
            if let result = result {
                for entry in result.entries {
                    if let fileMetadata = entry as? Files.FileMetadata {
                        let fileDestinationURL = destinationFolderURL.appendingPathComponent(fileMetadata.name)
                        self.downloadFile(fileMetadata: fileMetadata, to: fileDestinationURL)
                    } else if let subfolderMetadata = entry as? Files.FolderMetadata {
                        self.downloadFolder(folderMetadata: subfolderMetadata, to: destinationFolderURL)
                    }
                }
            } else if let error = error {
                print("Failed to list folder: \(error)")
            }
        }
    }
}

extension DropboxManageViewController{
    @objc func goBack() {
        var parentPath = (currentPath as NSString).deletingLastPathComponent
        if parentPath == "/"{
            parentPath = ""
        }
        loadFiles(path: parentPath)
        if parentPath.isEmpty {
            self.navigationItem.leftBarButtonItem = nil
        }
    }
    
    @objc func downloadSelectedFiles() {
        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        
        for file in selectedFiles {
            if let fileMetadata = file as? Files.FileMetadata {
                let fileDestinationURL = documentsURL.appendingPathComponent(fileMetadata.name)
                downloadFile(fileMetadata: fileMetadata, to: fileDestinationURL)
            } else if let folderMetadata = file as? Files.FolderMetadata {
                downloadFolder(folderMetadata: folderMetadata, to: documentsURL)
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

extension DropboxManageViewController:UITableViewDelegate, UITableViewDataSource{
    // MARK: - UITableViewDataSource
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CustomFileCell", for: indexPath) as! CustomFileCell
        let file = dataArray[indexPath.row]
        
        // 设置图标，标题和小标题
        cell.titleLabel.text = file.name
        if let folderMetadata = file as? Files.FolderMetadata {
            cell.iconImageView.image = UIImage(named: "folder_icon")
            cell.subtitleLabel.text = "\(folderCounts[folderMetadata.id] ?? 0)项"
        } else if let fileMetadata = file as? Files.FileMetadata {
            cell.iconImageView.image = UIImage(named: "file_icon")
            let fileSize = ByteCountFormatter.string(fromByteCount: Int64(fileMetadata.size), countStyle: .file)
            let dateFormatter = DateFormatter()
            dateFormatter.dateStyle = .short
            dateFormatter.timeStyle = .short
            let modifiedDate = dateFormatter.string(from: fileMetadata.clientModified)
            cell.subtitleLabel.text = "\(fileSize) | \(modifiedDate)"
        }
        
        // 设置选中按钮
        let imageName = selectedFiles.contains(file) ? "checkbox_1" : "checkbox_0"
        cell.checkboxImageView.setImage(UIImage(named: imageName), for: .normal)
        cell.checkClosure = { [weak self] in
            guard let self = self else{return}
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
        if let folderMetadata = file as? Files.FolderMetadata {
            loadFiles(path: folderMetadata.pathLower ?? "")
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

class CustomFileCell: UITableViewCell {
    var checkClosure:(()->())?
    
    let iconImageView = UIImageView()
    let titleLabel = UILabel()
    let subtitleLabel = UILabel()
    let checkboxImageView = UIButton(type: .custom)
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupViews()
    }
    
    private func setupViews() {
        iconImageView.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        checkboxImageView.translatesAutoresizingMaskIntoConstraints = false
        
        titleLabel.font = .systemFont(ofSize: 17, weight: .medium)
        
        subtitleLabel.textColor = .lightGray
        subtitleLabel.font = .systemFont(ofSize: 12)
        
        checkboxImageView.addTarget(self, action: #selector(checkAction), for: .touchUpInside)
        
        contentView.addSubview(iconImageView)
        contentView.addSubview(titleLabel)
        contentView.addSubview(subtitleLabel)
        contentView.addSubview(checkboxImageView)
        
        NSLayoutConstraint.activate([
            iconImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
            iconImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            iconImageView.widthAnchor.constraint(equalToConstant: 40),
            iconImageView.heightAnchor.constraint(equalToConstant: 40),
            
            titleLabel.leadingAnchor.constraint(equalTo: iconImageView.trailingAnchor, constant: 10),
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            titleLabel.trailingAnchor.constraint(equalTo: checkboxImageView.leadingAnchor, constant: -10),
            
            subtitleLabel.leadingAnchor.constraint(equalTo: iconImageView.trailingAnchor, constant: 10),
            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 5),
            subtitleLabel.trailingAnchor.constraint(equalTo: checkboxImageView.leadingAnchor, constant: -10),
            subtitleLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10),
            
            checkboxImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10),
            checkboxImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            checkboxImageView.widthAnchor.constraint(equalToConstant: 24),
            checkboxImageView.heightAnchor.constraint(equalToConstant: 24)
        ])
    }
    
    @objc func checkAction(){
        checkClosure?()
    }
}
