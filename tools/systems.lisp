(in-package "CLOG-TOOLS")
(defclass asdf-systems (clog:clog-panel)
          ((source-file :reader source-file) (files :reader files)
           (files-label :reader files-label) (deps :reader deps)
           (deps-label :reader deps-label)
           (loaded-systems :reader loaded-systems)
           (sys-label :reader sys-label)))
(defun create-asdf-systems
       (clog-obj &key (hidden nil) (class nil) (html-id nil) (auto-place t))
  (let ((panel
         (change-class
          (clog:create-div clog-obj :content
                           "<label for=\"CLOGB38680930412\" style=\"box-sizing: content-box; position: absolute; left: 10px; top: 7.99716px;\" id=\"CLOGB3868233956\" data-clog-name=\"sys-label\">Loaded Systems:</label><select size=\"4\" style=\"box-sizing: content-box; position: absolute; left: 10px; top: 38px; width: 239.716px; height: 261.341px;\" id=\"CLOGB3868233957\" data-clog-name=\"loaded-systems\"></select><label for=\"CLOGB38680988074\" style=\"box-sizing: content-box; position: absolute; left: 265px; top: 8px;\" class=\"\" id=\"CLOGB3868233958\" data-clog-name=\"deps-label\">Depends On:</label><select size=\"4\" style=\"box-sizing: content-box; position: absolute; left: 265px; top: 39.9858px; width: 310.361px; height: 76.3494px;\" id=\"CLOGB3868233959\" data-clog-name=\"deps\"></select><label for=\"\" style=\"box-sizing: content-box; position: absolute; left: 265px; top: 126px; width: 98.108px; height: 21.5px;\" id=\"CLOGB3868233960\" data-clog-name=\"files-label\">Files:</label><select size=\"4\" style=\"box-sizing: content-box; position: absolute; left: 265px; top: 151.991px; width: 311.562px; height: 146.932px;\" id=\"CLOGB3868233961\" data-clog-name=\"files\"></select><input type=\"TEXT\" value=\"\" style=\"box-sizing: content-box; position: absolute; left: 10px; top: 309.996px; width: 560.727px; height: 22.5px;\" id=\"CLOGB3868233962\" data-clog-name=\"source-file\">"
                           :hidden hidden :class class :html-id html-id
                           :auto-place auto-place)
          'asdf-systems)))
    (setf (slot-value panel 'source-file)
            (attach-as-child clog-obj "CLOGB3868233962" :clog-type
             'clog:clog-form-element :new-id t))
    (setf (slot-value panel 'files)
            (attach-as-child clog-obj "CLOGB3868233961" :clog-type
             'clog:clog-select :new-id t))
    (setf (slot-value panel 'files-label)
            (attach-as-child clog-obj "CLOGB3868233960" :clog-type
             'clog:clog-label :new-id t))
    (setf (slot-value panel 'deps)
            (attach-as-child clog-obj "CLOGB3868233959" :clog-type
             'clog:clog-select :new-id t))
    (setf (slot-value panel 'deps-label)
            (attach-as-child clog-obj "CLOGB3868233958" :clog-type
             'clog:clog-label :new-id t))
    (setf (slot-value panel 'loaded-systems)
            (attach-as-child clog-obj "CLOGB3868233957" :clog-type
             'clog:clog-select :new-id t))
    (setf (slot-value panel 'sys-label)
            (attach-as-child clog-obj "CLOGB3868233956" :clog-type
             'clog:clog-label :new-id t))
    (let ((target (sys-label panel)))
      (declare (ignorable target))
      (setf (attribute target "for")
              (clog:js-query target
                             "$('[data-clog-name=\\'loaded-systems\\']').attr('id')")))
    (let ((target (loaded-systems panel)))
      (declare (ignorable target))
      (dolist (n (asdf/operate:already-loaded-systems))
        (add-select-option target n n))
      (setf (text-value target) "clog")
      (asdf-browser-populate panel))
    (let ((target (deps-label panel)))
      (declare (ignorable target))
      (setf (attribute target "for")
              (clog:js-query target
                             "$('[data-clog-name=\\'deps\\']').attr('id')")))
    (let ((target (files-label panel)))
      (declare (ignorable target))
      nil)
    (clog:set-on-change (loaded-systems panel)
                        (lambda (target)
                          (declare (ignorable target))
                          (asdf-browser-populate panel)))
    (clog:set-on-double-click (deps panel)
                              (lambda (target)
                                (declare (ignorable target))
                                (setf (text-value (loaded-systems panel))
                                        (text-value target))
                                (asdf-browser-populate panel)))
    (clog:set-on-double-click (files panel)
                              (lambda (target)
                                (declare (ignorable target))
                                (let ((disp (select-text target))
                                      (item (text-value target)))
                                  (cond
                                   ((equal (subseq item (1- (length item)))
                                           "/")
                                    (setf (inner-html (files panel)) "")
                                    (dolist
                                        (n
                                         (asdf/component:module-components
                                          (asdf/component:find-component
                                           (asdf/system:find-system
                                            (text-value
                                             (loaded-systems panel)))
                                           (subseq disp 0
                                                   (1- (length disp))))))
                                      (let ((name
                                             (asdf/component:component-relative-pathname
                                              n))
                                            (path
                                             (asdf/component:component-pathname
                                              n)))
                                        (add-select-option (files panel) path
                                         name))))
                                   (t (on-open-file panel :open-file item))))))
    panel))