//
//  ViewController.swift
//  ThreadSample
//
//  Created by xiaopin on 2022/4/28.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        do_thread2()
    }

    func do_thread2(){
        OperationQueue
        //创建并列任务队列
        let queue = DispatchQueue(label: "com.xiaopin.semaphore.queue", qos: .default, attributes: .concurrent)
        //分组
        let group = DispatchGroup()
        weak var weakSelf = self
        queue.async(group: group) {
            //创建信号量
            let sema = DispatchSemaphore(value: 0)
            //执行异步操作，完成后sema.signal()
            <#异步操作代码#>
            
            //异步调用返回前，就会一直阻塞在这
            sema.wait()
        }
        
        queue.async(group: group) {
            //创建信号量
            let sema = DispatchSemaphore(value: 0)
            //执行异步操作，完成后sema.signal()
            <#异步操作代码#>
            
            //异步调用返回前，就会一直阻塞在这
            sema.wait()
        }
        
        //全部调用完成后回到主线程,再更新UI
        group.notify(queue: DispatchQueue.main, execute: {[weak self] in
            //tableView同时用到了两个请求到返回结果
            <#多个异步操作执行完以后的操作#>
        })
        
        DispatchWallTime
    }
    
    func do_thread1(){
        let queue = DispatchQueue.init(label: "nb.thread.111", qos: .default, attributes: .concurrent)
        queue.async {
            for i in 0..<3 {
                Thread.sleep(forTimeInterval: 2)
                NSLog("1111- %@",Thread.current)
            }
        }
        queue.async {
            for i in 0..<3 {
                Thread.sleep(forTimeInterval: 2)
                NSLog("2222- %@",Thread.current)
            }
        }
        
        let workItem = DispatchWorkItem.init(qos: .default, flags: .barrier) {
            NSLog("barrier")
        }
        queue.async(execute: workItem)
        
        queue.async {
            for i in 0..<3 {
                Thread.sleep(forTimeInterval: 2)
                NSLog("3333- %@",Thread.current)
            }
        }
        
        queue.async {
            for i in 0..<3 {
                Thread.sleep(forTimeInterval: 2)
                NSLog("4444- %@",Thread.current)
            }
        }
    }
}

