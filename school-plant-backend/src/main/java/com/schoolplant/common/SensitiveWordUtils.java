package com.schoolplant.common;

import org.springframework.util.StringUtils;

import java.util.*;

/**
 * 基于 DFA (Deterministic Finite Automaton) 算法的敏感词过滤工具类
 */
public class SensitiveWordUtils {

    // 敏感词库
    private static Map<Object, Object> sensitiveWordMap = null;

    // 默认内置敏感词库 (实际项目中可从数据库或文件中动态加载)
    private static final Set<String> DEFAULT_SENSITIVE_WORDS = new HashSet<>(Arrays.asList(
            "暴力", "色情", "赌博", "违禁", "代考", "枪支", "毒品", "办证", "发票", "洗钱", "迷药"
    ));

    static {
        initKeyWord(DEFAULT_SENSITIVE_WORDS);
    }

    /**
     * 初始化敏感词库，将敏感词加入到 HashMap 中，构建 DFA 算法模型
     */
    @SuppressWarnings({"unchecked", "rawtypes"})
    public static void initKeyWord(Set<String> keyWordSet) {
        sensitiveWordMap = new HashMap<>(keyWordSet.size());
        Map<Object, Object> nowMap;
        Map<Object, Object> newWorMap;

        for (String key : keyWordSet) {
            nowMap = sensitiveWordMap;
            for (int i = 0; i < key.length(); i++) {
                char keyChar = key.charAt(i);
                Object wordMap = nowMap.get(keyChar);

                if (wordMap != null) {
                    // 存在，则继续判断下一个字符
                    nowMap = (Map<Object, Object>) wordMap;
                } else {
                    // 不存在，构建一个新 Map，并设置 isEnd = "0"
                    newWorMap = new HashMap<>();
                    newWorMap.put("isEnd", "0");
                    nowMap.put(keyChar, newWorMap);
                    nowMap = newWorMap;
                }

                if (i == key.length() - 1) {
                    // 最后一个字符，将 isEnd 设置为 "1"
                    nowMap.put("isEnd", "1");
                }
            }
        }
    }

    /**
     * 检查文字中是否包含敏感字符
     *
     * @param text 待检测的文本
     * @return true = 包含，false = 不包含
     */
    public static boolean containsSensitiveWord(String text) {
        if (!StringUtils.hasText(text)) {
            return false;
        }
        for (int i = 0; i < text.length(); i++) {
            int matchFlag = checkSensitiveWord(text, i);
            if (matchFlag > 0) {
                return true;
            }
        }
        return false;
    }

    /**
     * 检查文字中是否包含敏感字符，并返回第一个匹配到的敏感词
     */
    public static String getFirstSensitiveWord(String text) {
        if (!StringUtils.hasText(text)) {
            return null;
        }
        for (int i = 0; i < text.length(); i++) {
            int matchFlag = checkSensitiveWord(text, i);
            if (matchFlag > 0) {
                return text.substring(i, i + matchFlag);
            }
        }
        return null;
    }

    /**
     * 检查文字中是否包含敏感字符，检查规则如下：
     *
     * @param txt        待检测文本
     * @param beginIndex 起始索引
     * @return 匹配到的敏感词长度，若未匹配到返回 0
     */
    @SuppressWarnings("rawtypes")
    private static int checkSensitiveWord(String txt, int beginIndex) {
        boolean flag = false;
        int matchFlag = 0;
        Map nowMap = sensitiveWordMap;
        for (int i = beginIndex; i < txt.length(); i++) {
            char word = txt.charAt(i);
            nowMap = (Map) nowMap.get(word);
            if (nowMap != null) {
                matchFlag++;
                if ("1".equals(nowMap.get("isEnd"))) {
                    flag = true;
                    // 这里采用最小匹配规则，如果要最大匹配，可以继续循环而不 break
                    break;
                }
            } else {
                break;
            }
        }
        if (matchFlag < 2 || !flag) { // 长度小于2或未匹配到结束标志，不算作敏感词
            matchFlag = 0;
        }
        return matchFlag;
    }

    /**
     * 动态添加敏感词 (可以在后台管理界面调用此方法动态刷新)
     */
    public static void addWord(String word) {
        if (!StringUtils.hasText(word)) return;
        DEFAULT_SENSITIVE_WORDS.add(word);
        initKeyWord(DEFAULT_SENSITIVE_WORDS);
    }
}
