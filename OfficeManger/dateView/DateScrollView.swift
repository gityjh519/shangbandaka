//
//  DateScrollView.swift
//  OfficeManger
//
//  Created by yaojinhai on 2020/9/4.
//  Copyright © 2020 yaojinhai. All rights reserved.
//

import Foundation
import SwiftUI
import UIKit


struct PageView<Page: View>: View {
    var viewControllers: [UIHostingController<Page>]
    @State var currentPage = 0
    init(_ views: [Page]) {
        self.viewControllers = views.map({ UIHostingController(rootView: $0)
        })
    }
    
    var body: some View {
        VStack {
            PageViewController(controllers: viewControllers, currentPage: $currentPage)
            Text(currentPage.description)
        }
    }
}

struct PageView_Previews: PreviewProvider {
    static var previews: some View {
        PageView([Text("abc"),Text("defabc")])
    }
}


struct PageViewController: UIViewControllerRepresentable {
    
    var controllers: [UIViewController]
    @Binding var currentPage: Int
    
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    func makeUIViewController(context: Context) -> UIPageViewController {
        let page = UIPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal);
        page.delegate = context.coordinator
        page.dataSource = context.coordinator
        return page
    }
    
    func updateUIViewController(_ uiViewController: UIPageViewController, context: Context) {
        
        uiViewController.setViewControllers([controllers[currentPage]], direction: .forward, animated: true)
    }
    
    class Coordinator: NSObject,UIPageViewControllerDelegate,UIPageViewControllerDataSource {
        var parent: PageViewController
        init(_ page: PageViewController) {
            parent = page;
        }
        
        func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
            
            guard let index = parent.controllers.firstIndex(of: viewController) else {
                return nil
            }
            let next = index + 1;
            if next == parent.controllers.count {
                return nil
            }
            return parent.controllers[next]
            
        }
        func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
            
            guard let index = parent.controllers.firstIndex(of: viewController) else {
                return nil
            }
            if index == 0 {
                return nil
            }
            return parent.controllers[index - 1]
        }
        func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
            if !completed {
                return
            }
            guard let currentController = pageViewController.viewControllers?.first else{
                return
            }
            let index = parent.controllers.firstIndex(of: currentController)
            if let idx = index {
                parent.currentPage = idx
            }
        }
    }
}
